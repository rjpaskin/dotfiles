$LOAD_PATH.unshift Tap.fetch("homebrew/bundle").path.join("lib").to_s
require "forwardable"
require "bundle"
require "cli/parser"

class CheckBrewfile
  attr_reader :brewfile

  def initialize
    args.parse

    filename = Homebrew.args.named.first || File.expand_path("../../setup/Brewfile", File.realpath(__FILE__))
    @brewfile = Bundle::Dsl.new(File.read filename)
  rescue => error
    @error = error
  end

  def print_report
    if invalid?
      return warn "#{error.message}\n#{error.backtrace.join("\n")}"
    end

    if tags.any?
      heading "Using these (normalised) tags:"
      log Formatter.columns(tags)
      log "\n"
    else
      warn "No tags detected"
    end

    if cask_arguments.any?
      log "cask_args #{Util.pretty_print cask_arguments}\n\n"
    end

    entries.each_cons(2).each_with_index do |(first, second), index|
      log first
      log second if index == entries.count - 2
      log "\n" if first.type != second.type
    end

    log "\n"
    heading "Summary"
    log type_counts.map {|type, count|
      "%-#{max_type_length + 1}s #{Tty.blue}%2d#{Tty.reset}" % [type, count]
    }.join " " * (max_type_length / 2)
  end

  private

  attr_reader :error

  def args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
      `check-brewfile` [<options>] [<Brewfile>]

      See what would be installed from the given Brewfile.
      EOS

      switch "--status",
        description: "Check Brewfile against currently installed formulae/casks"
      max_named 1
    end
  end

  def invalid?
    !@error.nil?
  end

  def tags
    ::SYSTEM_TAGS
  rescue NameError
    []
  end

  def entries
    @entries ||= begin
      brewfile.entries.map {|entry| EntryDecorator.new(entry) }.sort
    end
  end

  def type_counts
    @type_counts ||= entries.each_with_object(Hash.new 0) do |entry, acc|
      acc[entry.type] += 1
    end
  end

  def max_type_length
    @max_char_count ||= type_counts.keys.max_by(&:length).length
  end

  def cask_arguments
    brewfile.cask_arguments
  end

  def log(message)
    $stdout.puts message
  end

  def heading(message)
    $stdout.puts Formatter.headline(message)
  end

  def warn(message)
    $stderr.puts Formatter.warning(message)
  end

  module Util
    module_function

    def pretty_print(hash)
      hash.inspect.gsub(/(:(\w+)\s?=>\s?)/, "\\2: ").gsub(/(^{|}$)/, "")
    end
  end

  class EntryDecorator
    include Comparable

    SORT_ORDER = %w[tap brew cask mas].freeze

    attr_reader :original

    def initialize(original)
      @original = original
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def to_s
      %Q{#{installed_flag}#{type} #{Tty.blue}"#{name}"#{Tty.reset}#{options_to_s}}
    end

    def sort_key
      [SORT_ORDER.index(type) || -1, name]
    end

    def name
      original.name.start_with?("/") ? File.basename(original.name, ".rb") : original.name
    end

    def type
      original.type == :mac_app_store ? "mas" : original.type.to_s
    end

    private

    def installed_flag
      return "" unless Homebrew.args.status?

      if installed?
        $stdout.isatty ? "#{Tty.bold}#{Formatter.success "✔"}#{Tty.reset} " : "Y "
      else
        $stdout.isatty ? "#{Tty.bold}#{Formatter.error "✘"}#{Tty.reset} " : "N "
      end
    end

    def installed?
      case original.type
      when :brew
        Bundle::BrewInstaller.formula_installed?(name)
      when :cask
        [original.name, "caskroom/versions/#{original.name}"].any? do |cask|
          Bundle::CaskInstaller.cask_installed?(cask)
        end
      when :mac_app_store
        Bundle::MacAppStoreInstaller.app_id_installed?(options[:id])
      when :tap
        Bundle::TapInstaller.installed_taps.include?(original.name)
      end
    end

    def options
      original.options
    end

    def args
      options.fetch(:args, {})
    end

    def clone_target
      options[:clone_target]
    end

    def options_to_s
      case original.type
      when :brew, :mac_app_store
        ", #{Util.pretty_print options}" if options.any?
      when :cask
        ", #{Util.pretty_print options}" if args.any?
      when :tap
        ", #{clone_target.inspect}" if clone_target
      end
    end
  end
end

CheckBrewfile.new.print_report
