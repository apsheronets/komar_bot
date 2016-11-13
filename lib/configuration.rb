class MultiIO
  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

module Configuration
  class << self

    LOG_DIR = File.join(__dir__, '..', 'log')

    def new_logger
      env = ENV.fetch('APP_ENV', 'development')
      logfile = File.join(LOG_DIR, "#{env}.log")
      case env
      when 'development'
        @logger = Logger.new MultiIO.new(STDOUT, File.open(logfile, "a"))
        @logger.level = Logger::DEBUG
      else
        @logger = Logger.new logfile
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
