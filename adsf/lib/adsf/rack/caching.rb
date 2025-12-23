# frozen_string_literal: true

module Adsf::Rack
  class Caching
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = *@app.call(env)

      headers['cache-control'] ||= 'max-age=0, stale-if-error=0'

      [status, headers, body]
    end
  end
end
