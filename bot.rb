#!/usr/bin/ruby

require 'rubygems'
require 'telegram/bot'
require 'yaml'
require 'pp'
require './lib/configuration.rb'
require './lib/message_responder.rb'
require './lib/models.rb'

env = ENV.fetch('APP_ENV', 'development')

token = YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']

logger = Configuration.logger
chat_logger = Configuration.chat_logger

database_config = YAML::load(IO.read('config/database.yml'))[env]
ActiveRecord::Base.establish_connection database_config
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.logger = logger

def reoconnect_activerecord_until_avlie!
  begin
    while !ActiveRecord::Base.connection.active? do
      Configuration.logger.error 'database connection is dead'
      Configuration.logger.error 'reconnecting to DB in a second'
      sleep(1)
      ActiveRecord::Base.connection.reconnect!
    end
  rescue ActiveRecord::StatementInvalid
    retry
  end
end

polling_interval = env == 'development' ? 3 : nil
repond_timeout = 20

running = true
begin
  offset = TelegramUpdate.order('id DESC').first&.id
  logger.debug "starting with offset #{offset.inspect}"
  Telegram::Bot::Client.run(token, offset: offset, timeout: 2) do |bot|
    logger.info 'listening to telegram'
    responder = MessageResponder.new(bot)
    bot.listen do |message|
      TelegramUpdate.find_or_create_by(id: bot.offset)
      log_incoming message
      begin
        Timeout.timeout(repond_timeout) do
          responder.respond message
        end
      rescue => e
        logger.error e.message
        e.backtrace.each do |line|
          logger.info line
        end
        responder.answer_with_error message
        reoconnect_activerecord_until_avlie!
      end
    end
  end
rescue => e
  logger.error { e.inspect }
  e.backtrace.each do |line|
    logger.info line
  end
  Signal.trap('INT') { running = false }
  if running
    reoconnect_activerecord_until_avlie!
    logger.info "reconnecting to telegram in a second"
    sleep 1
    retry
  end
end
