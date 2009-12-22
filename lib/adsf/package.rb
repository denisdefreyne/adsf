require 'singleton'

module Adsf

  # Adsf::Package is a singleton that contains metadata about the adsf
  # project, which is used for packaging releases.
  class Package

    include Singleton

    # The name of the application.
    def name
      'adsf'
    end

    # The files to include in the package. This is also the list of files that
    # will be included in the documentation (with the exception of the files
    # in undocumented_files).
    def files
      @files ||= (%w( ChangeLog LICENSE NEWS.rdoc Rakefile README.rdoc ) +
        Dir['bin/**/*'] +
        Dir['lib/**/*']).reject { |f| File.directory?(f) }
    end

    # The Gem::Specification used for packaging.
    def gem_spec
      @gem_spec ||= Gem::Specification.new do |s|
        s.name                  = self.name
        s.version               = Adsf::VERSION
        s.platform              = Gem::Platform::RUBY
        s.summary               = 'a tiny static file server'
        s.description           = s.summary
        s.homepage              = 'http://stoneship.org/software/adsf/'
        s.rubyforge_project     = 'adsf'

        s.author                = 'Denis Defreyne'
        s.email                 = 'denis.defreyne@stoneship.org'

        s.required_ruby_version = '>= 1.8.5'

        s.has_rdoc              = false

        s.files                 = self.files
        s.executables           = [ 'adsf' ]
        s.require_path          = 'lib'
        s.bindir                = 'bin'
      end
    end

  end

end
