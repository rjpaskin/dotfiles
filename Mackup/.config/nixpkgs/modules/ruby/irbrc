#!/usr/bin/env ruby
require 'irb/completion'
require 'irb/ext/save-history'
require 'rubygems'
require 'pp'

IRB.conf[:EVAL_HISTORY] = 1000 # Store history in `__`
IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:HISTORY_FILE] = ENV.fetch("IRB_HISTORY_FILE") {
  File.join(
    ENV.fetch("XDG_DATA_HOME") { File.expand_path("~/.local/share") },
    "irb/history"
  )
}

IRB.conf[:PROMPT_MODE] = :SIMPLE

IRB.conf[:AUTO_INDENT] = true

if RUBY_PLATFORM =~ /darwin/
  def pbcopy(str)
    IO.popen('pbcopy', 'w') { |f| f << str.to_s }
  end

  def pbpaste
    `pbpaste`
  end
end

if defined?(Rails)
  def recognize_path(*args)
    Rails.application.routes.recognize_path(*args)
  end
end
