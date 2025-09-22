require "inih"

module ShellLib
  module INI
    module_function

    def parse(string)
      INIH.parse(string.to_s)
    end

    def load_file(file)
      INIH.load(file.respond_to?(:to_path) ? file.to_path : file.to_s)
    end
  end
end
