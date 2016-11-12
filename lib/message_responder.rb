MessageResponder = Struct.new(:bot) do

  MESSAGES = ['Иди на хуй', 'Хуита', 'Съеби']

  def respond(message)
    text = MESSAGES.sample
    send_message(chat_id: message.chat.id, text: text)
  end

  def send_message(args)
    log_line = sprintf(" => <%8s>: %s", args[:chat_id], args[:text])
    Configuration.logger.info log_line
    Configuration.chat_logger.info log_line
    bot.api.send_message(args)
  end
end
