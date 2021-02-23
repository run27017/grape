# frozen_string_literal: true

# when changing this file, run appraisal install ; rubocop -a gemfiles/*.gemfile

source('https://rubygems.org')

gemspec

group :development, :test do
  gem 'bundler'
  gem 'hashie'
  gem 'rake'
  gem 'rubocop', '1.7.0'
  gem 'rubocop-ast', '1.3.0'
  gem 'rubocop-performance', '1.9.1', require: false
end

group :development do
  gem 'appraisal'
  gem 'benchmark-ips'
  gem 'benchmark-memory'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end

group :test do
  gem 'cookiejar'
  gem 'coveralls_reborn'
  gem 'grape-entity', '~> 0.6'
  gem 'maruku'
  gem 'mime-types'
  gem 'pry-byebug'
  gem 'rack-jsonp', require: 'rack/jsonp'
  gem 'rack-test', '~> 1.1.0'
  gem 'rspec', '~> 3.0'
  gem 'ruby-grape-danger', '~> 0.2.0', require: false
end

platforms :jruby do
  gem 'racc'
end
