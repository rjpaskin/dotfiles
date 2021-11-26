require "etc"

module ShellLib
  autoload :Command, "shell_lib/command"
  autoload :ShellCommand, "shell_lib/shell_command"

  autoload :Path, "shell_lib/path"
  autoload :EditablePath, "shell_lib/editable_path"
  autoload :PathHelpers, "shell_lib/path_helpers"

  autoload :Output, "shell_lib/output"
  autoload :Program, "shell_lib/program"
  autoload :App, "shell_lib/app"
  autoload :Resource, "shell_lib/resource"
  autoload :ResourceHelpers, "shell_lib/resource_helpers"
  autoload :Runner, "shell_lib/runner"
  autoload :SearchPath, "shell_lib/search_path"

  autoload :Plist, "shell_lib/plist"
  autoload :StrictHash, "shell_lib/strict_hash"

  autoload :CachedMethods, "shell_lib/cached_methods"

  def self.arm?
    /arm64/i.match?(Etc.uname[:version])
  end
end
