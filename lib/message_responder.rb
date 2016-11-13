MessageResponder = Struct.new(:bot) do

  MESSAGES = ['Иди на хуй', 'Хуита', 'Съеби']

  def respond(message)
    text = MESSAGES.sample
    send(chat_id: message.chat.id, text: text)
  end

  def log_incoming(message)
    log_line = sprintf(" <= <%8s>: %s", message.chat.id, message.text)
    Configuration.logger.info log_line
    Configuration.chat_logger.info log_line
    Configuration.logger.debug message
  end

  def send(message)
    log_outgoing message
    bot.api.send_message message
  end

  def log_outgoing(message)
    log_line = sprintf(" => <%8s>: %s", message[:chat_id], message[:text])
    Configuration.logger.info log_line
    Configuration.chat_logger.info log_line
  end

  def answer_with_error(message)
    text = %{Sorry, something horrible happened. I hope my developer will handle this soon. Try again, huh?}
    send(chat_id: message.chat.id, text: text)
  end

end
