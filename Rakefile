require 'bundler/setup'

require 'active_record'

include ActiveRecord::Tasks

db_dir = File.expand_path('../db', __FILE__)
config_dir = File.expand_path('../config', __FILE__)

ActiveRecord.schema_format = :sql
DatabaseTasks.env = ENV['ENV'] || 'development'
DatabaseTasks.db_dir = db_dir
DatabaseTasks.database_configuration = YAML.safe_load(File.read(File.join(config_dir, 'database.yml')), aliases: true)
DatabaseTasks.migrations_paths = File.join(db_dir, 'migrate')

task :environment do
  ActiveRecord::Base.establish_connection DatabaseTasks.database_configuration[DatabaseTasks.env]
end

load 'active_record/railties/databases.rake'
