# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'komar_bot'
set :repo_url, "git@github.com:apsheronets/#{fetch :application}.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, :refucktoring

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'pids'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

after 'deploy:publishing', 'daemons:restart'

namespace :daemons do
  desc "restart the daemon"
  task :restart do
    on roles(:app) do
      within current_path do
        with app_env: fetch(:app_env) do
          execute :bundle, "exec ruby bin/bot restart"
        end
      end
    end
  end
  desc "start the daemon"
  task :start do
    on roles(:app) do
      within current_path do
        with app_env: fetch(:app_env) do
          execute :bundle, "exec ruby bin/bot start"
        end
      end
    end
  end
  desc "stop the daemon"
  task :stop do
    on roles(:app) do
      within current_path do
        with app_env: fetch(:app_env) do
          execute :bundle, "exec ruby bin/bot stop"
        end
      end
    end
  end
end

after 'deploy:publishing', 'deploy:migrate'

namespace :deploy do

  desc 'Runs rake db:migrate if migrations are set'
  task :migrate do
    on roles(:db) do
      conditionally_migrate = fetch(:conditionally_migrate)
      info '[deploy:migrate] Checking changes in db' if conditionally_migrate
      if conditionally_migrate && test("diff -qr #{release_path}/db #{current_path}/db")
        info '[deploy:migrate] Skip `deploy:migrate` (nothing changed in db)'
      else
        info '[deploy:migrate] Run `rake db:migrate`'
        invoke :'deploy:migrating'
      end
    end
  end

  desc 'Runs rake db:migrate'
  task :migrating do
    on roles(:db) do
      within release_path do
        with app_env: fetch(:app_env) do
          execute :rake, 'db:migrate'
        end
      end
    end
  end

  after 'deploy:updated', 'deploy:migrate'
end
