source 'https://rubygems.org'

ruby "2.3.0"

gem 'rails', '4.2.5.1'
gem 'bcrypt'
gem 'figaro'
gem 'rspec_api_documentation'
gem 'whenever', '~> 0.9.4'
gem 'shoulda-whenever', '~> 0.0.1'

group :development do
  gem 'letter_opener', '~> 1.4.1'
end

group :development, :test do
  gem 'spring'
  gem 'byebug'
  gem 'pry' # Not redundant as pry is capable of debugging within views, unlike byebug.
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
  gem 'dotenv-rails'
end

group :test do
  gem 'database_cleaner'
end
