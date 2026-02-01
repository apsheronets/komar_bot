source 'https://rubygems.org'

gem 'telegram-bot-ruby'
gem 'activerecord', '~> 7.0' # < 7.1 is a disaster
gem 'pg', '~> 1.5.0' # further versions are incompatible with bookworm
gem 'rake'
gem 'daemons'

# ruby <= 2.7 compatibility
gem 'nokogiri', '< 1.16'
gem 'securerandom', '< 0.4'
gem 'minitest', '~> 5.25.0'

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-scm-gitcopy'
end
