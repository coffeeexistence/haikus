source 'https://rubygems.org'

ruby "2.3.0"

gem 'rails', '4.2.5'
gem 'bcrypt'
gem 'figaro'
gem 'rspec_api_documentation'

group :development, :test do
  gem 'spring'
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.0'
  gem 'sqlite3'
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
end

group :production do
  gem 'pg'
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rvm'
end

