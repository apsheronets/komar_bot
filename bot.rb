#!/usr/bin/ruby

require 'rubygems'
require 'telegram/bot'
require 'yaml'
require 'pp'
require './lib/configuration.rb'
require './lib/message_responder.rb'

env = ENV.fetch('APP_ENV', 'development')

token = YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']

logger = Configuration.logger

running = true
begin
  Telegram::Bot::Client.run(token) do |bot|
    responder = MessageResponder.new(bot)
    bot.listen do |message|
      log_line = sprintf(" <= <%8s>: %s", message.chat.id, message.text)
      Configuration.logger.info log_line
      Configuration.chat_logger.info log_line
      logger.debug message
      responder.respond message
    end
  end
rescue => e
  logger.error { e.inspect }
  e.backtrace.each do |line|
    logger.info line
  end
  Signal.trap('INT') { running = false }
  if running
    logger.info "reconnecting in a second"
    sleep 1
    retry
  end
end
