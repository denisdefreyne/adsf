# frozen_string_literal: true

module Adsf::Rack
  class IndexFileFinder
    def initialize(app, root:, index_filenames: ['index.html'])
      @app = app
      @root = root
      @index_filenames = index_filenames
    end

    def call(env)
      # Get path
      path_info = ::Rack::Utils.unescape(env['PATH_INFO'])
      path = ::File.join(@root, path_info)

      # Redirect if necessary
      if ::File.directory?(path) && path_info !~ %r{/$}
        new_path_info = env['PATH_INFO'] + '/'
        return [
          302,
          { 'Location' => new_path_info, 'Content-Type' => 'text/html' },
          ["Redirecting you to #{new_path_info}&hellip;"],
        ]
      end

      # Add index file if necessary
      new_env = env.dup
      if ::File.directory?(path)
        index_filename = index_file_in(path)
        if index_filename
          new_env['PATH_INFO'] = ::File.join(path_info, index_filename)
        end
      end

      # Pass on
      @app.call(new_env)
    end

    private

    def index_file_in(dir)
      @index_filenames.find do |index_filename|
        ::File.file?(::File.join(dir, index_filename))
      end
    end
  end
end
