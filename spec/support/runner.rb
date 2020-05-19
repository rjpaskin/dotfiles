require "json"

require_relative "./command"
require_relative "./path"

class Runner
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
    run_in_shell!("which #{executable}").as_path
  end

  define_cached_method :shell_variable do |name|
    output = run_in_shell!("echo $#{name}").stdout.chomp

    if name == "PATH"
      output.as_search_path
    elsif output =~ %r{\A[0-9]+\z}
      Integer(output)
    else
      output
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

  def self.current
    Thread.current[:Runner] ||= new
  end

  def command(*args)
    Command.new(*args)
  end

  def command!(*args)
    command(*args).check!
  end

  def path(path_str)
    Path.new(path_str)
  end

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
    command(%W[env -i USER=#{ENV["USER"]} HOME=#{ENV["HOME"]} #{profile_bin("zsh")} -i -c] + args.flatten)
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

  def eval_nix(expression)
    run_in_shell!(
      "nix-instantiate --eval --strict --json --show-trace -E '#{expression}'"
    ).as_json
  end
end
