require "json"
require "tempfile"

module ShellLib
  class Runner
    extend CachedMethods

    define_cached_method :which do |executable|
      Resource.new("which #{executable}") { run_in_shell!("which #{executable}").as_path }
    end

    define_cached_method :shell_variable do |name|
      Resource.new("$#{name}") do
        output = run_in_shell!("echo $#{name}").stdout.chomp

        if name == "PATH"
          output.as_search_path
        elsif output =~ %r{\A[0-9]+\z}
          Integer(output)
        else
          output
        end
      end
    end

    GET_HOME_MANAGER_VALUE = <<~NIX
      (import <home-manager/modules> {
        configuration = ./Mackup/.config/nixpkgs/home.nix;
        pkgs = import <nixpkgs> {};
      }).%{expression}
    NIX

    define_cached_method :role_enabled? do |role|
      eval_nix(format GET_HOME_MANAGER_VALUE, expression: "config.roles.#{role}")
    end

    define_cached_method :neovim_variable do |name|
      eval_neovim("json_encode(#{name})").as_json
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

    def login_env
      @login_env ||= run_in_shell!("env").as_vars
    end

    def shell_functions
      @shell_functions ||= run_in_shell!("print -l ${(ko)functions}").lines
    end

    def shell_aliases
      @shell_aliases ||= run_in_shell!("alias").as_vars
    end

    def shell_alias(name)
      Resource.new("alias #{name}") { shell_aliases[name] }
    end

    def path_entry(path)
      path = Path.new(path)
      Resource.new("$PATH -> #{path}") { shell_variable("PATH")[path] }
    end

    def oh_my_zsh_plugins
      @oh_my_zsh_plugins ||= Resource.new("Oh-My-ZSH plugins") do
        run_in_shell!("print -l $plugins").lines
      end
    end

    def eval_nix(expression)
      run_in_shell!(
        "nix-instantiate --eval --strict --json --show-trace -E '#{expression}'"
      ).as_json
    end

    def nix_channel_urls
      @nix_channel_urls ||= run_in_shell!("nix-channel --list").as_vars(separator: " ")
    end

    NixChannel = Struct.new(:name, :url)

    def nix_channel(name)
      Resource.new("Nix channel '#{name}'") { NixChannel.new(name, nix_channel_urls[name]) }
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
