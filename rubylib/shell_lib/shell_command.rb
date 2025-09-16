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

      @stdout.gsub!(/\e\]\d+;?.+\e\\/, "") # strip shell integration (from Oh-My-ZSH)
      @stderr.gsub!(/\e\[.+\e\[00?m/, "") # strip prompt
    end

    def spawn_args
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
      ENV.slice(
        *LOGIN_ENV_KEYS,
        # Prevent error: "can't find terminal definition for xterm-ghostty"
        # on setting `TERMINFO_DIRS` or `TERM` in nix-darwin script sourced by /etc/zshenv
        *("TERMINFO" if ENV["TERM_PROGRAM"] == "ghostty")
      ).merge("PATH" => DEFAULT_PATH)
    end
  end
end
