#!/usr/bin/env ruby
require "pathname"
require "set"

module SystemTags
  module_function

  SETUP_FILES = %w[Brewfile bootstrap.sh dock.sh basics.sh].map {|file| "setup/#{file}" }
  DOTFILES = %w[.bash_profile .tmux.conf .zshrc .zlogin].map {|file| "Mackup/#{file}" }

  def run
    files = (SETUP_FILES + DOTFILES).map &method(:Pathname)

    files.inject(SortedSet.new) do |tags, file|
      begin
        tags.merge(extract_tags file)
      rescue Errno::ENOENT
        $stderr.puts "Skipping '#{file}', file does not exist"
        tags
      end
    end
  end

  TAG_USAGE = %r{
    \b
    (has_tag|tag\?|brew_if_tagged|cask_if_tagged) # method or function call
    (\s+|\()                                      # spaces or open bracket
    ["':]                                         # quote or colon
    (?<tag_name>[A-Za-z0-9_-]+)                   # actual tag name
    ["']?                                         # quote - not for symbols
  }x

  ALL_WHITESPACE = /^\s+$/

  def extract_tags(file)
    file.each_line.inject(SortedSet.new) do |tags, line|
      next(tags) if line.start_with?("#") || line =~ ALL_WHITESPACE

      matches = line.match(TAG_USAGE)

      with_debugging_on_failure(tags, line, matches) do
        next(tags) unless matches
        tags << matches[:tag_name].gsub("-", "_")
      end
    end
  end

  def with_debugging_on_failure(*vars)
    yield
  rescue => err
    p "---------ERR---------"
    vars.each &method(:p)
    p "---------ERR---------"
    raise
  end

  def print_tags(io = $stdout)
    result = run.to_a

    output = if $stdout.stat.file? # being redirected to file
      result.join(" ").gsub("_", "-") # dashes look nicer
    else # being piped or output to terminal
      result.join("\n")
    end

    io.puts output
  end
end

SystemTags.print_tags if $0 == __FILE__
