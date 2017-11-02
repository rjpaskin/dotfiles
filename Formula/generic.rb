# -*- ruby -*-

require 'formula'
require 'fileutils'

$LOAD_PATH.unshift Formula["brew-gem"].prefix/"lib"

require 'brew/gem'

class RubyGemsDownloadStrategy < AbstractDownloadStrategy
  def self.with_ruby_env
    env = {
      "PATH" => PATH.new(RUBY_BIN, ENV["HOMEBREW_PATH"]),
      "GEM_SPEC_CACHE" => HOMEBREW_CACHE/"gem_spec_cache"
    }

    with_env(env) { yield }
  end

  def fetch
    ohai "Fetching #{resource.url} from gem source"
    HOMEBREW_CACHE.cd do
      self.class.with_ruby_env do
        safe_system "gem", "fetch", resource.url, "--version", resource.version
      end
    end
  end

  def cached_location
    HOMEBREW_CACHE/"#{resource.url}-#{resource.version}.gem"
  end

  def clear_cache
    cached_location.unlink if cached_location.exist?
  end
end

module GenericBrewGem
  def self.generate(filename)
    gem_name = File.basename(filename, ".rb").sub(/^gem-/, "")
    class_name = gem_name.capitalize.gsub(/[-_.\s]([a-zA-Z0-9])/) { $1.upcase }.gsub('+', 'x')

    Object.const_set("Gem#{class_name}", Class.new(Formula) do
      url gem_name, :using => RubyGemsDownloadStrategy
      version RubyGemsDownloadStrategy.with_ruby_env { Brew::Gem::CLI.fetch_version(gem_name) }

      def gem_name
        stable.url
      end

      def install
        # Copy user's RubyGems config to temporary build home.
        home = Pathname(`eval printf "~$USER"`)
        buildpath_gemrc = Pathname("#{ENV['HOME']}/.gemrc")

        if (home/".gemrc").exist? && !buildpath_gemrc.exist?
          cp(home/".gemrc", buildpath_gemrc)
        end

        # set GEM_HOME and GEM_PATH to make sure we package all the dependent gems
        # together without accidently picking up other gems on the gem path since
        # they might not be there if, say, we change to a different rvm gemset
        ENV['GEM_HOME'] = prefix.to_s
        ENV['GEM_PATH'] = prefix.to_s

        gem_path = RUBY_BIN/"gem"
        ruby_path = RUBY_BIN/"ruby"
        system gem_path, "install", cached_download,
                 "--no-ri",
                 "--no-rdoc",
                 "--no-wrapper",
                 "--no-user-install",
                 "--install-dir", prefix,
                 "--bindir", bin

        raise "gem install '#{gem_name}' failed with status #{$?.exitstatus}" unless $?.success?

        bin.rmtree if bin.exist?
        bin.mkpath

        brew_gem_prefix = prefix/"gems/#{gem_name}-#{version}"

        completion_for_bash = Dir[
                                brew_gem_prefix/"completion{s,}/#{gem_name}.{bash,sh}",
                                brew_gem_prefix/"**/{_,-,}#{gem_name}{_,-}completion{s,}{.bash,.sh,}"
                              ].first
        bash_completion.install completion_for_bash if completion_for_bash

        completion_for_zsh = Dir[
                               brew_gem_prefix/"completion{s,}/#{gem_name}.zsh",
                               brew_gem_prefix/"**/#{gem_name}{_,-}completion{s,}.zsh"
                             ].first
        zsh_completion.install completion_for_zsh if completion_for_zsh

        gemspec = Gem::Specification::load (prefix/"specifications/#{gem_name}-#{version}.gemspec").to_s
        ruby_libs = Dir.glob(prefix/"gems/*/lib")
        gemspec.executables.each do |exe|
          file = brew_gem_prefix/"#{gemspec.bindir}/#{exe}"
          (bin/file.basename).open('w') do |f|
            f << <<~RUBY
              #!#{ruby_path} --disable-gems
              ENV['GEM_HOME']="#{prefix}"
              ENV['GEM_PATH']="#{prefix}"
              require 'rubygems'
              $:.unshift(#{ruby_libs.map(&:inspect).join(",")})
              load "#{file}"
            RUBY
          end
        end
      end
    end)
  end
end
