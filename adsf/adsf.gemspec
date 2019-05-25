# frozen_string_literal: true

require_relative 'lib/adsf/version'

Gem::Specification.new do |s|
  s.name                  = 'adsf'
  s.version               = Adsf::VERSION
  s.platform              = Gem::Platform::RUBY
  s.summary               = 'a tiny static file server'
  s.description           = 'A web server that can be spawned in any directory'
  s.homepage              = 'http://github.com/ddfreyne/adsf/'
  s.license               = 'MIT'

  s.author                = 'Denis Defreyne'
  s.email                 = 'denis.defreyne@stoneship.org'

  s.required_ruby_version = '~> 2.3'
  s.add_runtime_dependency('rack', '>= 1.0.0', '< 3.0.0')

  s.files                 = ['NEWS.md', 'README.md'] + Dir['bin/**/*'] + Dir['lib/**/*.rb']
  s.executables           = ['adsf']
  s.require_path          = 'lib'
  s.bindir                = 'bin'
end
