require "etc"

module ShellLib
  autoload :Command, "shell_lib/command"
  autoload :ShellCommand, "shell_lib/shell_command"

  autoload :Path, "shell_lib/path"
  autoload :EditablePath, "shell_lib/editable_path"
  autoload :PathHelpers, "shell_lib/path_helpers"

  autoload :Output, "shell_lib/output"
  autoload :Program, "shell_lib/program"
  autoload :Resource, "shell_lib/resource"
  autoload :ResourceHelpers, "shell_lib/resource_helpers"
  autoload :Runner, "shell_lib/runner"
  autoload :SearchPath, "shell_lib/search_path"

  autoload :StrictHash, "shell_lib/strict_hash"

  autoload :CachedMethods, "shell_lib/cached_methods"

  ARM_ARCH = "arm64".freeze

  def self.arm?
    Etc.uname[:machine] == ARM_ARCH
  end
end
