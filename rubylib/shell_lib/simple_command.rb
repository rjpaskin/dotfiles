module ShellLib
  # To allow a command to run purely for its side-effects,
  # e.g. stdout and stderr are connected to the terminal and not captured
  class SimpleCommand < Command
    BLANK = "".freeze

    private

    def execute
      system(to_s)

      # stdout and stderr are unavailable, as they've
      # already been passed to the inherited FDs
      [BLANK, BLANK, $?]
    end
  end
end
