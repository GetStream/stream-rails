source "https://rubygems.org"
gemspec path: '..'

gem 'rake', '< 11.0'
gem 'actionpack', '~> 3.0'
gem 'railties', '~> 3.0'
gem 'activerecord', '~> 3.0'
gem 'simplecov', :require => false, :group => :test