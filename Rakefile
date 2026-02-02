require 'bundler/setup'
require 'active_record'
require_relative "lib/activerecord_default_credentials.rb"

include ActiveRecord::Tasks

ActiveRecord.schema_format = :sql
DatabaseTasks.env = "production" # It has to be a string, not a symbol,
                                 # for some fucking reason.
DatabaseTasks.db_dir = File.expand_path('db', __dir__)
config = {
  database: Etc.getlogin # The rake db:migrate command fails if this is missing.
                         # For some reason it only happens in rake.
}
config.merge!(ActiverecordDefaultCredentials)
config.merge!(YAML.safe_load(
    File.read(File.expand_path('settings.yml', __dir__)),
    aliases: true,
    symbolize_names: true
  ).try("[]", :activerecord) || {}
)
DatabaseTasks.database_configuration = { "production" => config }
DatabaseTasks.migrations_paths = File.expand_path('db/migrate', __dir__)

task :environment do
  ActiveRecord::Base.establish_connection DatabaseTasks.database_configuration[DatabaseTasks.env]
end

load 'active_record/railties/databases.rake'
