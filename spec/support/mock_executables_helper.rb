require "json"
require "eventmachine"

module MockExecutablesHelper
  Invocation = Struct.new(:name, :args, :sudo) do
    alias_method :sudo?, :sudo

    def self.parse(raw)
      new(
        *JSON.parse(raw, symbolize_names: true).values_at(:name, :args, :sudo)
      )
    end

    def to_s
      [*("sudo" if sudo?), name, *args].join(" ")
    end
  end

  class Server < EventMachine::Connection
    include EventMachine::Protocols::LineProtocol

    attr_reader :registry

    def self.run(registry)
      ENV["DOTFILES_SOCKET"] = socket = File.expand_path("../../tmp/dotfiles.sock", __dir__)

      Thread.new do
        Thread.current[:calls] = []

        EventMachine.run do
          EventMachine.start_unix_domain_server(socket, self, registry)
        end
      end

      yield
    ensure
      EventMachine.stop if EventMachine.reactor_running?
    end

    def initialize(registry)
      @registry = registry
    end

    def receive_line(line)
      invocation = Invocation.parse(line)
      Thread.current[:calls] << invocation
      response = registry.send(invocation.name, invocation)
      response = { stdout: response.to_s } unless Hash === response

      send_data("#{response.to_json}\n")
    end
  end

  class Client < EventMachine::Connection
    include EventMachine::Protocols::LineProtocol

    def self.run(arg0, args)
      socket = ENV.fetch("DOTFILES_SOCKET")

      EventMachine.run do
        EventMachine.connect_unix_domain(socket, self, arg0, args)
        EventMachine.add_timer(2) { EventMachine.stop } # timeout
      end
    end

    attr_reader :name, :args, :sudo

    def initialize(arg0, args)
      @name = File.basename(arg0)
      @args = args.dup

      @sudo = /^(builtins_)?sudo$/.match?(@name)
      @name = @args.shift if @sudo

      @args.map! do |arg|
        arg.start_with?("/dev/fd") ? File.read(arg) : arg
      end
    end

    def post_init
      payload = { name: name, args: args, sudo: sudo }

      send_data("#{payload.to_json}\n")
    end

    def receive_line(line)
      response = JSON.parse(line, symbolize_names: true)

      $stdout.puts response[:stdout] if response[:stdout]
      $stderr.puts response[:stderr] if response[:stderr]

      EventMachine.stop
      exit(response[:status] || 0)
    end
  end

  # Relies on `bin` being defined (as a method or `let`)
  def stub_command(name, **options, &block)
    bin.join(name).write(<<~SCRIPT).mk_executable
      #!#{RbConfig::CONFIG["bindir"]}/ruby
      require \"bundler/setup\"
      require \"#{__FILE__}\"

      MockExecutablesHelper::Client.run($0, ARGV)
    SCRIPT

    to_match = { sudo: false }.merge(options)

    allow(registry).to receive(name, &block).with(
      an_object_having_attributes(to_match)
    )
  end

  def an_invocation_of(name, with:, sudo: false)
    an_object_having_attributes(name: name, args: with, sudo: sudo)
  end

  def a_sudo_invocation_of(name, with:)
    an_invocation_of(name, with: with, sudo: true)
  end

  MACOS_VERSIONS = {
    mojave: "10.14.6",
    big_sur: "11.5.0"
  }.freeze

  def stub_os(macos_version:, arch:)
    stub_command("sw_vers", args: %w[-productVersion]).and_return(
      MACOS_VERSIONS[macos_version] || macos_version
    )

    stub_command("uname", args: %w[-m]).and_return(arch)
  end

  def calls
    EventMachine.reactor_thread[:calls]
  end
end
