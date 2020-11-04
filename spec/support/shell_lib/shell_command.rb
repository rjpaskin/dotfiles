module ShellLib
  class ShellCommand < Command
    # See:
    # - https://opensource.apple.com/source/system_cmds/system_cmds-433/login.tproj/login.c.auto.html
    # - `/usr/bin/script /dev/null /usr/bin/login -fq $USER env`
    LOGIN_ENV_KEYS = %w[HOME SHELL TERM LOGNAME USER].freeze

    # See: https://opensource.apple.com/source/Libc/Libc-320/include/paths.h.auto.html
    DEFAULT_PATH = "/usr/bin:/bin".freeze

    private

    def run
      super

      @stderr.gsub!(/\e\[.+\e\[00?m/, "") # strip prompt
    end

    def open3_args
      [
        env,
        ENV["SHELL"],
        "-i", # interactive (loads .zshrc, enables history, shows prompt)
        "-l", # login
        "-s", # read from stdin
        unsetenv_others: true,
        # prepend command with spaces to avoid committing to history
        stdin_data: command.join(" ").gsub(/^/, " ")
      ]
    end

    def env
      ENV.slice(*LOGIN_ENV_KEYS).merge("PATH" => DEFAULT_PATH)
    end
  end
end
