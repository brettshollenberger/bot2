#!/usr/bin/env ruby

require 'rubygems' 
require 'daemons'
require 'clockwork'

Daemons.run_proc('clockwork') do
  require_relative 'clock.rb'
  run
end
