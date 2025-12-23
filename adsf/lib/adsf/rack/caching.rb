# frozen_string_literal: true

module Adsf::Rack
  class Caching
    DEFAULT_HEADERS = {
      'cache-control' => 'max-age=0, stale-if-error=0',
    }.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = *@app.call(env)

      headers = DEFAULT_HEADERS.merge(headers)

      [status, headers, body]
    end
  end
end
