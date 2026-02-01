ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile', __dir__)
require 'rubygems'
require 'bundler/setup'
require 'telegram/bot'
require 'psych'

Dir[File.expand_path('lib/*.rb', __dir__)].each {|lib| require lib}

module Application
  extend self

  def env
    @env ||= ENV.fetch('APP_ENV', 'development')
  end

  def load_config(filename)
    begin
      Psych.unsafe_load(IO.read(File.join(__dir__, 'config', filename)), freeze: true)[env]
    rescue => e
      logger.error "while reading config #{filename}: #{e}"
      raise e
    end
  end

  def secrets
    unless @secrets
      name = "secrets.yml"
      hash = load_config name
      ensure_config_contains(name, hash, "telegram_bot_token")
      @secrets = hash
    end
    @secrets
  end

  def database_config
    @database_config ||= load_config "database.yml"
  end

  def telegram_bot_token
    @telegram_bot_token ||= secrets["telegram_bot_token"]
  end

  def establish_activerecord!(app_name: nil)
    self.name = app_name if self.name.nil? && !(app_name.nil?)
    establish_activerecord_for_threads(pool: 1)
    prepare_connection
  end

  def establish_activerecord_for_threads(pool:)
    if pool
      config = database_config.merge({ "pool" => pool })
    else
      config = database_config
    end
    ActiveRecord::Base.establish_connection config
    ActiveRecord.default_timezone = :utc # ActiveRecord 7
    #ActiveRecord::Base.default_timezone = :utc # ActiveRecord <= 6
    ActiveRecord::Base.logger = logger
  end

  def prepare_connection
    set_postgresql_application_name
  end

  def set_postgresql_application_name
    ActiveRecord::Base.connection.execute "SET application_name='#{name.to_s}_#{Process.pid}';" if name
  end

  def restart_activerecord_connection
    # There are no checks if connection is alive for a purpose.
    # It's because ActiveRecord 7 reconnects automatically
    # and doesn't do the prepare_connection "callback".
    begin
      loop do
        return false unless running
        logger.info "reconnecting to database"
        ActiveRecord::Base.connection.reconnect!
        prepare_connection
        return true
      end
    rescue ActiveRecord::StatementInvalid, PG::ConnectionBad, PG::Error
      logger.info 'failed to reconnect to database; reconnecting in 3 seconds'
      sleep(3)
      retry
    end
  end

  def handle_if_db_connection_problem(e)
    case e
    when ActiveRecord::StatementInvalid, PG::ConnectionBad, PG::Error
      Application.restart_activerecord_connection
    end
  end

  attr_accessor :running, :signal, :name
  def trap_signals!
    ["INT", "TERM", "QUIT"].each do |s|
      Signal.trap(s) do
        Application.signal = s
        Application.running = false
      end
    end
    Application.running = true
  end

  def exit_point
    if running == false
      if name
        logger.info "exiting #{name} process gracefully due to SIG#{signal}"
      else
        logger.info "exiting process gracefully due to SIG#{signal}"
      end
      exit 0
    end
  end

  class MultiLogger
    Levels = %i(debug info warn error fatal any).freeze
    def initialize(loggers)
      @loggers = loggers
      @min_level = loggers.map(&:level).min
      Levels.each do |level|
        define_singleton_method(level) do |*args|
          @loggers.each do |logger|
            logger.send(level, *args)
          end
        end
      end
      Levels.each do |level|
        define_singleton_method(level.to_s + "?") do |*args|
          @min_level <= Levels.index(level)
        end
      end
    end

    def level
      @min_level
    end

  end

  def logger
    unless @logger
      levels = %i(debug info warn error fatal any).freeze
      case env
      when "development"
        log_level = :debug
      else
        log_level = :info
      end
      loggers = []
      loggers << Logger.new(STDOUT, level: log_level) if $stdout.tty?
      %i(error info debug).each do |level|
        loggers << Logger.new(File.expand_path("./log/#{level}", __dir__), level: level) if levels.index(log_level) <= levels.index(level)
      end
      @logger = MultiLogger.new loggers
    end
    @logger
  end

  def chat_logger
    unless @chat_logger
      @chat_logger = Logger.new(File.expand_path("./log/chat", __dir__))
      @chat_logger.formatter = proc do |serverity, time, progname, msg|
        "#{time} #{msg}\n"
      end
    end
    @chat_logger
  end

  def name=(x)
    unless x == @name
      Process.setproctitle x
      @name = x
    end
  end

  private

  def ensure_config_contains(config_name, hash, *path)
    if hash.nil? || hash.dig(*path).nil?
      message = "#{env}.#{path.join(".")} is not set in #{config_name}"
      logger.fatal message
      raise message
    end
  end
end
