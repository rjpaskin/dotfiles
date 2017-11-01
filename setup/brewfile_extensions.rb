SYSTEM_TAGS = begin
  tag_file = ENV.fetch("SYSTEM_TAG_FILE") { File.join(ENV["HOME"], ".system_tags") }

  File.open(tag_file, "r") {|f| f.read }.gsub("-", "_").chomp.split(/\s+/)
rescue
  warn "WARNING: Unable to read tags file '#{tag_file}'"
  []
end

def tag?(tag_name)
  SYSTEM_TAGS.include? tag_name.to_s.gsub("-", "_")
end

def if_tagged(type, name, options = {})
  send(type, name, options) if tag? name
end

def brew_if_tagged(name, options = {})
  if_tagged :brew, name, options
end

def cask_if_tagged(name, options = {})
  if_tagged :cask, name, options
end


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
