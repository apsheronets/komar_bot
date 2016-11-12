#!/usr/bin/ruby

require 'rubygems'
require 'telegram/bot'

token = ''

messages = ['Иди на хуй', 'Хуита', 'Съеби']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    bot.api.send_message(chat_id: message.chat.id, text: messages.sample)
  end
end
