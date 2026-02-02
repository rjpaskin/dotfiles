require "rubygems"

module ShellLib
  class MacOSVersion
    include Comparable

    VERSIONS = {
      tahoe:    "26",
      sequoia:  "15",
      sonoma:   "14",
      ventura:  "13",
      monterey: "12",
      big_sur:  "11",
      catalina: "10.15",
      mojave:   "10.14"
    }.freeze

    VERSIONS.each do |name, version|
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def self.#{name}
          @#{name} ||= new("#{version}")
        end

        def #{name}?
          ::Gem::Reguirement.new("~> #{version}.0").satisfied_by?(version)
        end
      RUBY
    end

    def self.current
      @current ||= begin
        version = Runner.current.command!("sw_vers -productVersion")
        new(version.chomp)
      end
    end

    def initialize(string)
      @version = ::Gem::Version.new(string)
    end

    def <=>(other)
      case other
      when self.class
        version <=> other.send(:version)
      when Symbol, String
        raise ArgumentError, "Invalid version: #{other}" unless VERSIONS.key?(other.to_sym)

        self <=> self.class.public_send(other)
      end
    end

    def to_s
      version.to_s
    end

    def inspect
      "#<#{self.class} #{version}>"
    end

    private

    attr_reader :version
  end
end
