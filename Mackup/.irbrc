#!/usr/bin/env ruby
require 'irb/completion'
require 'irb/ext/save-history'
require 'rubygems'
require 'pp'

IRB.conf[:EVAL_HISTORY] = 1000 # Store history in `__`
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = ENV.fetch("IRB_HISTORY_FILE") { File.expand_path("~/.irb_history") }

IRB.conf[:PROMPT_MODE] = :SIMPLE

IRB.conf[:AUTO_INDENT] = true

def pbcopy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def pbpaste
  `pbpaste`
end
