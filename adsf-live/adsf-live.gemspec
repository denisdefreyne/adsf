# frozen_string_literal: true

require_relative 'lib/adsf/live/version'

Gem::Specification.new do |s|
  s.name                  = 'adsf-live'
  s.version               = Adsf::Live::VERSION
  s.platform              = Gem::Platform::RUBY
  s.summary               = 'livereload support for adsf'
  s.description           = 'Automatically reloads when changes are detected.'
  s.homepage              = 'http://github.com/ddfreyne/adsf/'
  s.license               = 'MIT'

  s.author                = 'Denis Defreyne'
  s.email                 = 'denis.defreyne@stoneship.org'

  s.required_ruby_version = '>= 2.3'

  s.add_runtime_dependency('adsf', '~> 1.3')
  s.add_runtime_dependency('em-websocket', '~> 0.5')
  s.add_runtime_dependency('eventmachine', '~> 1.2')
  s.add_runtime_dependency('listen', '~> 3.0')
  s.add_runtime_dependency('rack-livereload', '~> 0.3')

  s.files                 = ['NEWS.md', 'README.md'] + Dir['lib/**/*.rb']
  s.require_path          = 'lib'
end
