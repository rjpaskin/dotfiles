$LOAD_PATH.unshift Tap.fetch("homebrew/bundle").path.join("lib").to_s
require "forwardable"
require "bundle/dsl"

class CheckBrewfile
  attr_reader :brewfile

  def initialize(filename)
    @brewfile = Bundle::Dsl.new(File.read filename)
  rescue => error
    @error = error
  end

  def print_report
    if invalid?
      return warn "#{error.message}\n#{error.backtrace.join("\n")}"
    end

    if tags.any?
      log "Using these (normalised) tags:\n#{tags.join(" ")}\n"
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
  end

  private

  attr_reader :error

  def invalid?
    !@error.nil?
  end

  def tags
    brewfile.singleton_class::SYSTEM_TAGS
  rescue NameError
    []
  end

  def entries
    @entries ||= begin
      brewfile.entries.map {|entry| EntryDecorator.new(entry) }.sort
    end
  end

  def cask_arguments
    brewfile.cask_arguments
  end

  def log(message)
    $stdout.puts message
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
    extend Forwardable

    SORT_ORDER = [:tap, :brew, :cask, :mac_app_store].freeze

    attr_reader :original
    def_delegators :original, :type, :name, :options

    def initialize(original)
      @original = original
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def to_s
      %Q{#{display_type} #{Tty.blue}"#{name}"#{Tty.reset}#{options_to_s}}
    end

    def sort_key
      [SORT_ORDER.index(type) || -1, name]
    end

    private

    def display_type
      type == :mac_app_store ? "mas" : type.to_s
    end

    def args
      options.fetch(:args, {})
    end

    def clone_target
      options[:clone_target]
    end

    def options_to_s
      case type
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

CheckBrewfile.new(
  ENV.fetch("BREWFILE") {
    File.expand_path("../../setup/Brewfile", __FILE__)
  }
).print_report
