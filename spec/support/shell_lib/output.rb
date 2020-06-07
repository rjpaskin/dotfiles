module ShellLib
  class Output < String
    def split(*args)
      super.map! {|line| self.class.new(line) }
    end

    def ==(other)
      return super(other.to_s) if other.is_a?(Path)

      super
    end

    def lines
      split(/\r?\n/)
    end

    def line
      lines.first
    end

    def include?(matcher)
      return self =~ matcher if matcher.is_a?(Regexp)

      super
    end

    def as_vars(separator: "=")
      lines.each_with_object({}) do |line, env|
        name, value = line.split(separator, 2)
        env[name] = value.gsub(/(^'|'$)/, "") # strip surrounding quotes
      end
    end

    def as_path
      Path.new(line)
    end

    def as_search_path
      SearchPath.parse(line)
    end

    def as_json
      JSON.parse(self, symbolize_names: true)
    end
  end
end
