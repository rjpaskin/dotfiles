SYSTEM_TAGS = begin
  tag_file = ENV.fetch("SYSTEM_TAG_FILE") { File.join(ENV["HOME"], ".system_tags") }

  File.read(tag_file).gsub("-", "_").chomp.split(/\s+/)
rescue
  warn "WARNING: Unable to read tags file '#{tag_file}'"
  []
end

MY_FORMULA_DIR = File.expand_path("../../Formula", __FILE__)

def tag?(tag_name)
  SYSTEM_TAGS.include? tag_name.to_s.gsub("-", "_")
end

def brew_gem(name, options = {})
  brew File.join(MY_FORMULA_DIR, "gem-#{name}.rb"), options
end

def method_missing(name, *args, &block)
  if name.to_s =~ /(.+)_if_tagged$/
    send($1, name, options) if tag? $1
  else
    super
  end
end

# Monkey patches
if defined? ::Bundle::BrewInstaller
  ::Bundle::BrewInstaller.prepend Module.new {
    def initialize(name, options = {})
      super
      @pin = options.fetch(:pin, false)
    end

    private

    def install!
      install_result = super

      if install_result == :failed || !@pin
        return install_result
      end

      puts "Pinning #{@name} formula" if ARGV.verbose?
      if Bundle.system("brew", "pin", @full_name, *@args)
        :success
      else
        :failed
      end
    end
  }
end

if defined? ::Bundle::Dsl
  ::Bundle::Dsl.singleton_class.prepend Module.new {
    def sanitize_brew_name(name)
      return name if name.start_with? "/"

      super
    end
  }
end
