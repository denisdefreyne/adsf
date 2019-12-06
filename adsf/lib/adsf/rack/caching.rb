# frozen_string_literal: true

module Adsf::Rack
  class Caching
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = *@app.call(env)

      new_headers =
        headers.merge(
          'Cache-Control' => 'max-age=0, stale-if-error=0',
        )

      [status, new_headers, body]
    end
  end
end
