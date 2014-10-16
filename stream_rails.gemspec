# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'stream_rails/version'

Gem::Specification.new do |s|
  s.name = 'stream_rails'
  s.version = StreamRails::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Tommaso Barbugli"]
  s.email = "tbarbugli@gmail.com"
  s.homepage = 'https://github.com/GetStream/stream-rails'
  s.summary = ""
  s.description = ""

  s.files = `git ls-files lib`.split("\n") + ['Gemfile','Rakefile','README.md', 'MIT-LICENSE']
  s.test_files = `git ls-files test`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.2'

  if File.exists?('UPGRADING')
    s.post_install_message = File.read("UPGRADING")
  end
end