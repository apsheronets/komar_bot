module Configuration
  class << self

    LOG_DIR = File.join(__dir__, '..', 'log')

    def new_logger
      env = ENV.fetch('APP_ENV', 'development')
      case env
      when 'development'
        @logger = Logger.new STDOUT
        @logger.level = Logger::DEBUG
      else
        @logger = Logger.new File.join(LOG_DIR, "#{env}.log")
        @logger.level = Logger::INFO
      end
      return @logger
    end

    def logger
      @logger || self.new_logger
    end

    def new_chat_logger
      env = ENV.fetch('APP_ENV', 'development')
      @chat_logger = Logger.new File.join(LOG_DIR, "#{env}.chatlog")
      @chat_logger.formatter = proc do |serverity, time, progname, msg|
        "#{time} #{msg}\n"
      end
      return @chat_logger
    end

    def chat_logger
      @chat_logger || self.new_chat_logger
    end

  end
end
