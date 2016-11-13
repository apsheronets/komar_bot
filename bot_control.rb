#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'daemons'
require 'telegram/bot'
require 'yaml'
require './lib/configuration.rb'
require './lib/message_responder.rb'
require './lib/models.rb'

Daemons.run('bot.rb', multiple: false, monitor: true, log_output: true, output_logfilename: 'log/daemons.out')
