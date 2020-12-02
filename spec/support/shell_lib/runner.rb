require "json"
require "shellwords"
require "tempfile"

module ShellLib
  class Runner
    extend CachedMethods
    include PathHelpers

    define_cached_method :which do |executable|
      path = run_in_shell!("which -a #{executable}").lines.find {|line| line.start_with?("/") }

      path && path.as_path
    end

    define_cached_method :manpage do |name|
      run_in_shell!("man --path #{name}").as_path
    end

    define_cached_method :shell_variable do |name|
      Resource.new("$#{name}") do
        output = run_in_shell!("echo $#{name}").stdout.chomp

        if name =~ /^(F|NIX_)?PATH$/
          output.as_search_path
        elsif output =~ %r{\A[0-9]+\z}
          Integer(output)
        else
          output
        end
      end
    end

    define_cached_method :neovim_variable do |name|
      eval_neovim("json_encode(#{name})").as_json
    end

    define_cached_method :shell_functions, key_optional: true do |type|
      name = [*type, "functions"].join("_")
      run_in_shell!("print -l ${(ko)#{name}}").lines
    end

    def self.current
      Thread.current[:Runner] ||= new
    end

    def command(*args)
      Command.new(*args)
    end

    def command!(*args)
      command(*args).check!
    end

    def run_in_shell(*args)
      ShellCommand.new(*args)
    end

    def run_in_shell!(*args)
      run_in_shell(*args).check!
    end

    def shell_command!(*args)
      Resource.new(%{zsh -c "#{args.join " "}"}) { run_in_shell!(*args) }
    end

    def program(name)
      Resource.new("program #{name}") { Program.new(name) }
    end

    def login_env
      @login_env ||= run_in_shell!("env").as_vars
    end

    def shell_aliases
      @shell_aliases ||= run_in_shell!("alias").as_vars
    end

    def shell_alias(name)
      Resource.new("alias #{name}") { shell_aliases[name] }
    end

    def path_entry(path)
      path = file(path)
      Resource.new("$PATH -> #{path}") { shell_variable("PATH")[path] }
    end

    def manpath
      @manpath ||= run_in_shell!("manpath").as_search_path
    end

    def manpath_entry(path)
      path = file(path)
      Resource.new("manpath -> #{path}") { manpath[path] }
    end

    def fpath_entry(path)
      path = file(path)
      Resource.new("$FPATH -> #{path}") { shell_variable("FPATH")[path] }
    end

    def oh_my_zsh_plugins
      @oh_my_zsh_plugins ||= Resource.new("Oh-My-ZSH plugins") do
        run_in_shell!("print -l $plugins").lines
      end
    end

    def home_manager_roles
      @home_manager_roles ||= nix_profiles_path(
        "home-manager/rjp/roles.json"
      ).as_json
    end

    def role_enabled?(role)
      @role_overrides ||= ENV["ENABLED_ROLES"].to_s.split(",")
      return true if @role_overrides.include?(role.to_s)

      home_manager_roles.fetch(role.to_sym) { raise "No role defined: '#{role}'" }
    end

    def nix_path_entry(name)
      if name.is_a?(Symbol)
        Resource.new("$NIX_PATH -> <#{name}>") { shell_variable("NIX_PATH")[name] }
      else
        path = file(name)
        Resource.new("$NIX_PATH -> #{path}") { shell_variable("NIX_PATH")[path] }
      end
    end

    EVAL_NEOVIM_EXPRESSION = "redir @\">|silent echo %{expression}|redir END" \
      "|enew|put|write! %{tmpfile}|quit!".freeze

    def eval_neovim(expression)
      Tempfile.open("eval_neovim") do |tmpfile|
        run_in_shell!(
          "nvim -n -i NONE -c '#{format(EVAL_NEOVIM_EXPRESSION, expression: expression, tmpfile: tmpfile.path)}'"
        )

        Output.new(tmpfile.tap(&:rewind).read)
      end
    end

    def neovim_packages
      @neovim_packages ||= Resource.new("Neovim packages") do
        eval_neovim("&runtimepath").split(",").grep(%r{/share/vim-plugins/[^/]+$}).map! do |pkg|
          File.basename(pkg)
        end
      end
    end

    def neovim_keymappings
      @neovim_keymappings ||= begin
        eval_neovim(
          %[execute("map") . "\n" . execute("map!")]
        ).strip.split("\n").each_with_object(deep_hash) do |line, map|
          mode, key, function_or_special, function = line.split(/\s+/, 4)
          function ||= function_or_special

          map[mode][key] = function
        end
      end
    end

    GIT_CONFIG_VALUES = {
      "true" => true,
      "false" => false
    }.freeze

    def git_config
      @git_config ||= begin
        run_in_shell!("git --no-pager config --global --list --includes").lines.each_with_object(deep_hash) do |line, config|
          key, value = line.split("=", 2)
          *parts, last = key.split(".").map!(&:to_sym)

          config.dig(*parts)[last] = GIT_CONFIG_VALUES.fetch(value, value)
        end
      end
    end

    private

    def deep_hash
      default = proc {|hash, key| hash[key] = Hash.new(&default) }

      Hash.new(&default)
    end
  end
end
