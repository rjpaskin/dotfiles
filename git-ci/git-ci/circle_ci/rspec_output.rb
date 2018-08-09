module GitCI
  class CircleCI
    RSpecOutput = Struct.new(:message) do
      ANSI_CODE = /\e\[([;\d]+)?m/m

      def tests
        commands = message.to_s
          .split(/\r\n\r\nFailed examples:\r\n\r\n/).last
          .split(/\r\n\r\nRandomized with seed/).first

        commands.each_line.map do |command|
          strip_ansi(command).strip.sub("rspec ./", "")
        end
      end

      private

      def strip_ansi(string)
        string.gsub(ANSI_CODE, "")
      end
    end
  end
end
