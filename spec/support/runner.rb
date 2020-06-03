require "json"
require "tempfile"
require "delegate"

require_relative "./command"
require_relative "./shell_command"
require_relative "./path"

class Runner
  class Resource < SimpleDelegator
    attr_reader :name

    def initialize(name, &block)
      @name = name
      @block = block
    end

    def to_s
      name.to_s
    end

    def __getobj__
      __setobj__(block.call) unless defined?(@__called)
      @__called = true
      super
    end

    def inspect
      "#<#{name} #{__getobj__.inspect}>"
    end

    private

    attr_reader :block
  end

  class << self
    attr_reader :cache_blocks
  end

  @cache_blocks = {}

  def self.define_cached_method(name, &block)
    @cache_blocks[name.to_sym] = block
    escaped_name = name.to_s.sub(/[!?]$/, "")

    class_eval <<~RUBY, __FILE__, __LINE__ + 1
      def #{escaped_name}_cache
        @#{escaped_name}_cache ||= begin
          block = self.class.cache_blocks.fetch(:#{name})

          Hash.new do |cache, value|
            cache[value] = instance_exec(value, &block)
          end
        end
      end

      private :#{escaped_name}_cache

      def #{name}(value)
        #{escaped_name}_cache[value]
      end
    RUBY
  end

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

  def file(path_str)
    Path.new(path_str)
  end

  alias_method :directory, :file

  HOME = Path.new("~").freeze
  NIX_PROFILE = HOME.join(".nix-profile").freeze

  def profile_path(path)
    NIX_PROFILE.join(path)
  end

  def profile_bin(path)
    profile_path("bin/#{path}")
  end

  def home
    HOME
  end

  def home_path(path)
    HOME.join(path)
  end

  def xdg_config_path(path)
    home_path(".config/#{path}")
  end

  def xdg_data_path(path)
    home_path(".local/share/#{path}")
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

  def nix_channels
    @nix_channels ||= run_in_shell!("nix-channel --list").as_vars(separator: " ")
  end

  def nix_channel(name)
    Resource.new("Nix channel '#{name}'") { nix_channels[name] }
  end

  EVAL_NEOVIM_EXPRESSION = "redir @\">|silent echo %{expression}|redir END" \
    "|enew|put|write! %{tmpfile}|quit!".freeze

  def eval_neovim(expression)
    Tempfile.open("eval_neovim") do |tmpfile|
      run_in_shell!(
        "nvim -n -i NONE -c '#{format(EVAL_NEOVIM_EXPRESSION, expression: expression, tmpfile: tmpfile.path)}'"
      )

      Command::Output.new(tmpfile.tap(&:rewind).read)
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
