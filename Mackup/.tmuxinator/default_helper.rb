require "pathname"
require "yaml"

class DefaultHelper
  def initialize(name)
    @name = name
  end

  def root
    path.to_s.sub ENV["HOME"], "~"
  end

  def windows
    format_for_yaml window_commands.map {|key, value| { key.to_s => value.to_s } }
  end

  def on_start
    cmds = []

    cmds << run("mailcatcher", port: 1025) if arg? :mailcatcher
    cmds << brew(:start, "mongodb") if arg? /^mongo/
    cmds << brew(:start, "memcached") if arg? /^memcache/
    cmds << brew(:start, "redis") if gem? "sidekiq"

    if arg? :elasticsearch
      cmds << %Q{export ELASTICSEARCH_URL="http://127.0.0.1:9222"}
      cmds << add_to_path("~/src/lib/elasticsearch-#{arg :elasticsearch}/bin")
      cmds << run("elasticsearch -d -Des.http.port=9222", port: 9222)
    end

    if arg? :postgres
      cmds << add_to_path("$(brew --prefix)/opt/postgresql-#{arg :postgres}/bin")
    end

    format_for_yaml cmds
  end

  def on_stop
    cmds = [%Q{tmux send-keys -t #{name}:editor ":wa" "Enter" ":qa" "Enter"}]

    if docker?
      cmds << "docker-compose kill"
    elsif interruptable_windows.any?
      cmds << %Q{for win in #{interruptable_windows.join " "}; do tmux send-keys -t #{name}:$win "C-c"; done}
    end

    cmds << kill_port(1025) if arg? :mailcatcher
    cmds << brew(:stop, "mongodb") if arg? /^mongo/
    cmds << brew(:stop, "memcached") if arg? /^memcache/
    cmds << brew(:stop, "redis") if gem? "sidekiq"
    cmds << kill_port(9222) if arg? :elasticsearch

    format_for_yaml cmds
  end

  def ruby_version
    if exists? ".ruby-version"
      path.join(".ruby-version").read.chomp
    else
      `rbenv global`.chomp
    end
  end

  private

  attr_reader :args, :settings, :name

  def args
    @args ||= ENV["MUX_SETTINGS"].to_s.split(" ").inject({}) do |acc, arg|
      key, value = arg.split(/[:=]/, 2)
      acc.merge! key => value
    end
  end

  def arg?(arg_name)
    if arg_name.is_a? Regexp
      args.any? {|key| key =~ arg_name }
    else
      args.any? {|key| key == arg_name.to_s }
    end
  end

  def arg(key, default = nil)
    args.fetch(key.to_s, default)
  end

  def path
    @path ||= Pathname.new(ENV["HOME"]).join("src", name)
  end

  def exists?(*filenames)
    path.join(*filenames).exist?
  end

  def format_for_yaml(value)
    return if value.empty?

    value.to_yaml.gsub("---\n", "").gsub(/^-/m, "  -").chomp
  end

  def base_windows
    {
      editor: "vim",
      shell: ""
    }
  end

  def docker_windows
    docker_compose = "docker_compose_exec_when_up app"

    {
      console: "#{docker_compose} #{rails :c}",
      server: "#{docker_compose} #{rails :s}",
      spec: "#{docker_compose} bash",
      dshell: "#{docker_compose} bash",
      docker: "BYEBUG=1 docker-compose up"
    }
  end

  def window_commands
    @window_commands ||= base_windows.tap do |base|
      return base.merge!(docker_windows) if docker?

      base.merge!(
        console: rails(:c),
        server: server
      )

      base.merge! guard: command(:guard) if exists? "Guardfile"

      base.merge! worker: command(:rake, "jobs:work") if gem? "delayed_job"
      base.merge! worker: command(:sidekiq, "-C ./config/sidekiq.yml") if gem? "sidekiq"

      base.merge! log: %{tail -f log/development.log | grep -vE "(^\s*$|Started GET \"/assets/)"}

      if arg? :postgres
        base.merge! postgres: "postgres -D $(brew --prefix)/var/postgresql-#{arg :postgres}"
      end
    end
  end

  def interruptable_windows
    window_commands.keys & [:console, :server, :guard, :worker, :log, :postgres]
  end

  def docker?
    exists? "docker-compose.yml"
  end

  def server
    if exists? "Procfile"
      "heroku local --port 3000"
    else
      rails :s
    end
  end

  def gem?(name)
    return false if docker? # gems aren't installed outside container

     gemfile =~ /gem ["']#{name}["']/i
  end

  def gemfile
    return "" unless exists?("Gemfile")

    @gemfile ||= path.join("Gemfile").read
  end

  def run(command, port:)
    "lsof -i :#{port} > /dev/null || #{command}"
  end

  def add_to_path(dir)
    "export PATH=#{dir}:$PATH"
  end

  def brew(verb, formula)
    "brew services #{verb} #{formula}"
  end

  def kill_port(port)
    "kill $(lsof -ti :#{port})"
  end

  def command(name, *args)
    exe = if exists?("bin", name.to_s)
      "bin/#{name}"
    elsif exists?("bin", "bundle")
      "bin/bundle exec #{name}"
    else
      "bundle exec #{name}"
    end

    [exe, *args].join(" ")
  end

  def rails(*args)
    command :rails, *args
  end
end
