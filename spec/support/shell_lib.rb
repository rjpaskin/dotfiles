module ShellLib
  autoload :Command, "shell_lib/command"
  autoload :ShellCommand, "shell_lib/shell_command"

  autoload :Path, "shell_lib/path"
  autoload :PathHelpers, "shell_lib/path_helpers"

  autoload :Output, "shell_lib/output"
  autoload :Resource, "shell_lib/resource"
  autoload :ResourceHelpers, "shell_lib/resource_helpers"
  autoload :Runner, "shell_lib/runner"
  autoload :SearchPath, "shell_lib/search_path"

  autoload :CachedMethods, "shell_lib/cached_methods"
end
