module Adsf
  class Server
    DEFAULT_HANDLER_NAME = :thin

    def initialize(root:, index_filenames: ['index.html'], host: '127.0.0.1', port: 3000, handler: nil)
      @root = root
      @index_filenames = index_filenames
      @host = host
      @port = port
      @handler = handler

      @q = SizedQueue.new(1)
    end

    def run
      handler = build_handler
      app = build_app(root: @root, index_filenames: @index_filenames)

      url = "http://#{@host}:#{@port}/"
      puts "View the site at #{url}"

      handler.run(app, Host: @host, Port: @port) do |server|
        wait_for_stop_async(server)
      end
    end

    def stop
      @q << true
    end

    private

    def wait_for_stop_async(server)
      Thread.new { wait_for_stop(server) }
    end

    def wait_for_stop(server)
      @q.pop
      server.stop
    end

    def build_app(root:, index_filenames:)
      ::Rack::Builder.new do
        use ::Rack::CommonLogger
        use ::Rack::ShowExceptions
        use ::Rack::Lint
        use ::Rack::Head
        use Adsf::Rack::IndexFileFinder,
            root: root,
            index_filenames: index_filenames

        run ::Rack::File.new(root)
      end.to_app
    end

    def build_handler
      if @handler
        ::Rack::Handler.get(@handler)
      else
        begin
          ::Rack::Handler.get(DEFAULT_HANDLER_NAME)
        rescue LoadError
          ::Rack::Handler::WEBrick
        end
      end
    end
  end
end
