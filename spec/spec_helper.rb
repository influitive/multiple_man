require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'bundler/setup'
require 'bunny'
require 'ostruct'
require 'pry'

require_relative '../lib/multiple_man.rb'