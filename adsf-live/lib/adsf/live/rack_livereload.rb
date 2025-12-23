# frozen_string_literal: true

module Rack
  class LiveReload
    LIVERELOAD_JS_PATH = '/__rack/livereload.js'
    VENDORED_JS_PATH = "#{__dir__}/../../../vendor/livereload.js"
    HEAD_TAG_REGEX = /<head( [^<]+)?>/.freeze
    LIVERELOAD_PORT = 35_729
    LIVERELOAD_SCHEME = 'ws'

    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      return deliver_file(VENDORED_JS_PATH) if env['PATH_INFO']&.end_with? LIVERELOAD_JS_PATH

      status, headers, body = result = @app.call(env)

      if env['REQUEST_METHOD'] != 'GET' ||
         headers['content-type'] !~ %r{text/html} ||
         headers['transfer-encoding'] == 'chunked' ||
         headers['content-disposition'] =~ /^inline/
        return result
      end

      body.close if body.respond_to?(:close)
      new_body = []
      livereload_added = false
      @env = env
      body.each do |line|
        if !livereload_added && line =~ HEAD_TAG_REGEX
          new_body << line.sub(HEAD_TAG_REGEX) { |match| %(#{match}#{template}) }
          livereload_added = true
        else
          new_body << line
        end
      end
      headers['content-length'] = new_body.sum(&:bytesize).to_s
      headers['x-rack-livereload'] = '1' if livereload_added

      [status, headers, new_body]
    end

    private

    def deliver_file(file)
      [
        200,
        { 'content-type' => 'text/javascript', 'content-length' => ::File.size(file).to_s, 'cache-control' => 'public, max-age=3600, immutable' },
        [::File.read(file)],
      ]
    end

    def template
      <<~HTML
        <script>
          RACK_LIVERELOAD_PORT = #{@options[:live_reload_port] || LIVERELOAD_PORT}
          RACK_LIVERELOAD_SCHEME = "#{@options[:live_reload_scheme] || LIVERELOAD_SCHEME}"
        </script>
        <script defer src="#{livereload_source}?host=#{host_to_use}"></script>
      HTML
    end

    def livereload_source
      if @options[:source] == :vendored
        LIVERELOAD_JS_PATH
      else
        "#{@options[:protocol] || 'http'}://#{host_to_use}/livereload.js"
      end
    end

    def host_to_use
      (@options[:host] || @env['HTTP_HOST'] || 'localhost').sub(/:.*/, '')
    end
  end
end
