# -*- ruby -*-

require 'formula'
require 'fileutils'

$LOAD_PATH.unshift Formula["brew-gem"].prefix/"lib"

require 'brew/gem'

class RubyGemsDownloadStrategy < AbstractDownloadStrategy
  def fetch
    ohai "Fetching tmuxinator from gem source"
    HOMEBREW_CACHE.cd do
      ENV['GEM_SPEC_CACHE'] = "#{HOMEBREW_CACHE}/gem_spec_cache"
      safe_system RUBY_BIN/"gem", "fetch", "tmuxinator", "--version", resource.version
    end
  end

  def cached_location
    Pathname.new("#{HOMEBREW_CACHE}/tmuxinator-#{resource.version}.gem")
  end

  def clear_cache
    cached_location.unlink if cached_location.exist?
  end
end

class GemTmuxinator < Formula
  def self._remote_version
    with_env("PATH" => PATH.new(RUBY_BIN, ENV["HOMEBREW_PATH"]), "GEM_SPEC_CACHE" => "#{HOMEBREW_CACHE}/gem_spec_cache") do
      Brew::Gem::CLI.fetch_version("tmuxinator")
    end
  end

  url "tmuxinator", :using => RubyGemsDownloadStrategy
  version _remote_version

  OLD_HOME = ENV["HOME"]

  def install
    # Copy user's RubyGems config to temporary build home.
    buildpath_gemrc = "#{ENV['HOME']}/.gemrc"
    if File.exists?(OLD_HOME+'/.gemrc') && !File.exists?(buildpath_gemrc)
      FileUtils.cp(OLD_HOME+'/.gemrc', buildpath_gemrc)
    end

    # set GEM_HOME and GEM_PATH to make sure we package all the dependent gems
    # together without accidently picking up other gems on the gem path since
    # they might not be there if, say, we change to a different rvm gemset
    ENV['GEM_HOME']="#{prefix}"
    ENV['GEM_PATH']="#{prefix}"

    gem_path = RUBY_BIN/"gem"
    ruby_path = RUBY_BIN/"ruby"
    system gem_path, "install", cached_download,
             "--no-ri",
             "--no-rdoc",
             "--no-wrapper",
             "--no-user-install",
             "--install-dir", prefix,
             "--bindir", bin

    raise "gem install 'tmuxinator' failed with status #{$?.exitstatus}" unless $?.success?

    bin.rmtree if bin.exist?
    bin.mkpath

    brew_gem_prefix = prefix+"gems/tmuxinator-#{version}"

    completion_for_bash = Dir[
                            "#{brew_gem_prefix}/completion{s,}/tmuxinator.{bash,sh}",
                            "#{brew_gem_prefix}/**/{_,-,}tmuxinator{_,-}completion{s,}{.bash,.sh,}"
                          ].first
    bash_completion.install completion_for_bash if completion_for_bash

    completion_for_zsh = Dir[
                           "#{brew_gem_prefix}/completions/tmuxinator.zsh",
                           "#{brew_gem_prefix}/**/tmuxinator{_,-}completion{s,}.zsh"
                         ].first
    zsh_completion.install completion_for_zsh if completion_for_zsh

    gemspec = Gem::Specification::load("#{prefix}/specifications/tmuxinator-#{version}.gemspec")
    ruby_libs = Dir.glob("#{prefix}/gems/*/lib")
    gemspec.executables.each do |exe|
      file = Pathname.new("#{brew_gem_prefix}/#{gemspec.bindir}/#{exe}")
      (bin+file.basename).open('w') do |f|
        f << <<-RUBY
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
end
