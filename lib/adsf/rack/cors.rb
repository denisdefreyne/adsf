# frozen_string_literal: true

module Adsf::Rack
  class CORS
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = *@app.call(env)

      new_headers =
        headers.merge(
          'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept, Range',
        )

      [status, new_headers, body]
    end
  end
end
