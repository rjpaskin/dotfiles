module GitCI
  class CircleCI
    class Build < JSONStruct
      accessors :build_num, :status, :subject, :branch, :vcs_revision, :build_time_millis, :start_time

      alias_method :num, :build_num

      def initialize(data, detail: :commit_message)
        @detail = detail

        super(data)
      end

      def status
        case @status
        when "fixed"    then "success"
        when "canceled" then "cancelled"
        when "not_run"  then "skipped"
        else @status
        end
      end

      def status_colour
        case status
        when "success" then Tty.green
        when "running" then Tty.cyan
        when "failed" then Tty.red
        when "queued" then Tty.purple
        else Tty.grey
        end
      end

      def time
        return "-- --" unless build_time_millis || start_time

        seconds = if build_time_millis
          build_time_millis / 1000
        elsif start_time
          Time.now.utc - Time.parse(start_time)
        end

        format "%2d'%02d", *seconds.divmod(60)
      end

      def sha
        vcs_revision[0..6]
      end

      def commit_message
        return "" unless subject

        subject[0..77].tap do |str|
          str << "..." if str != subject
        end
      end

      def detail
        case @detail
        when :commit_message then commit_message
        when :branch then branch
        end
      end

      def to_ary
        [
          coloured(status),
          coloured("##{num}"),
          "#{Tty.yellow}#{sha}#{Tty.reset}",
          "#{Tty.grey}#{detail}#{Tty.reset}",
          coloured(time)
        ].map(&:to_s)
      end

      private

      def coloured(text)
        "#{status_colour}#{text}#{Tty.reset}"
      end
    end
  end
end
