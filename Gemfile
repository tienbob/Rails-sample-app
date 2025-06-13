source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "tzinfo-data"
gem "sassc-rails",     "~> 2.1"
gem "propshaft"
gem "bcrypt",        "~> 3.1"
gem "importmap-rails", "~> 1.1"
gem "turbo-rails",     "~> 1.4"
gem "stimulus-rails",  "~> 1.2"
gem "jbuilder",        "~> 2.11"
gem "puma",            "~> 6.0"
gem "bootsnap",        "~> 1.16", require: false
gem "fiddle", "~> 1.1.0"
gem "rails-controller-testing"
group :development, :test do
  gem "sqlite3", "~> 2.1"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "minitest"             
  gem "minitest-reporters"   
  gem "guard"        
  gem "guard-minitest"     
end

group :production do
  gem "pg", "~> 1.3"
  gem "solid_cache"
  gem "solid_queue"
end