# frozen_string_literal: true

module Adsf
  class Server
    def initialize(
      root:,
      live: false,
      host: '127.0.0.1',
      port: 3000,
      index_filenames: ['index.html'],
      auto_extensions: [],
      handler: nil
    )
      @root = root
      @live = live
      @index_filenames = index_filenames
      @auto_extensions = auto_extensions
      @host = host
      @port = port
      @handler = handler

      @q = SizedQueue.new(1)
    end

    def run
      handler = build_handler
      app = build_app(
        root: @root,
        index_filenames: @index_filenames,
        auto_extensions: @auto_extensions,
      )
      start_watcher if @live

      url = "http://#{@host}:#{@port}/"
      puts "View the site at #{url}"

      handler.run(app, Host: @host, Port: @port) do |server|
        wait_for_stop_async(server)
      end
    end

    def stop
      @q << true
    end

    # Tell clients to reload the specified paths, or (by default) all paths.
    def live_reload(paths = [nil])
      @watcher.reload(paths)
    end

    private

    def start_watcher
      require 'adsf/live'

      @watcher = ::Adsf::Live::Watcher.new(
        root_dir: File.absolute_path(@root),
        watch_files: @live != :manual,
      )
      @watcher.start
    end

    def wait_for_stop_async(server)
      Thread.new { wait_for_stop(server) }
    end

    def wait_for_stop(server)
      @q.pop
      server.stop
    end

    def build_app(root:, index_filenames:, auto_extensions:)
      is_live = @live

      ::Rack::Builder.new do
        use ::Rack::CommonLogger
        use ::Rack::ShowExceptions
        use ::Rack::Lint
        use ::Rack::Head
        use Adsf::Rack::Caching
        use Adsf::Rack::CORS
        use Adsf::Rack::IndexFileFinder,
            root: root,
            index_filenames: index_filenames
        use Adsf::Rack::AutoFileExtensions,
            root: root,
            extensions: auto_extensions

        if is_live
          require 'adsf/live'
          use ::Rack::LiveReload, no_swf: true, source: :vendored
        end

        run ::Rack::Files.new(root)
      end.to_app
    end

    def build_handler
      if @handler
        ::Rackup::Handler.get(@handler)
      else
        ::Rackup::Handler.default
      end
    end
  end
end
