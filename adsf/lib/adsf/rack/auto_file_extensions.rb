# frozen_string_literal: true

module Adsf::Rack
  class AutoFileExtensions
    def initialize(app, root:, extensions:)
      @app = app
      @root = root
      # Search list starts with '' so that we first look for file as requested
      @search_suffixes = [''] + Array(extensions).map { |ext| ".#{ext}" }
    end

    def call(env)
      path_info = ::Rack::Utils.unescape(env['PATH_INFO'])
      path = ::File.join(@root, path_info)

      new_env = env
      @search_suffixes.each do |suffix|
        new_path = path + suffix
        next unless ::File.exist?(new_path)

        new_env = env.dup # only dup if needed
        new_env['PATH_INFO'] += suffix
        break
      end

      @app.call(new_env)
    end
  end
end
