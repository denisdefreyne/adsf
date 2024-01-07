# frozen_string_literal: true

module Adsf::Rack
  class AutoFileExtensions
    def initialize(app, root:, extensions:)
      @app = app
      @root = root
      # Search list starts with '' so that we first look for file as requested
      @extensions = [''] + Array(extensions)
    end

    def call(env)
      path_info = ::Rack::Utils.unescape(env['PATH_INFO'])
      path = ::File.join(@root, path_info)

      new_env = env
      @extensions.each do |ext|
        new_path = path + ext
        next unless ::File.exist?(new_path)

        new_env = env.dup # only dup if needed
        new_env['PATH_INFO'] += ext
        break
      end

      @app.call(new_env)
    end
  end
end
