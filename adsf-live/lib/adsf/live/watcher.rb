# frozen_string_literal: true

module Adsf
  module Live
    class Watcher
      def initialize(root_dir:)
        unless Pathname.new(root_dir).absolute?
          raise ArgumentError, 'Watcher#initialize: The root_path argument must be an absolute path'
        end

        @root_dir = root_dir
      end

      def start
        @server = start_server
        @listener = start_listener(@server)
      end

      def stop
        @listener&.stop
        @server&.stop
      end

      def start_server
        ::Adsf::Live::WebSocketServer.new(
          host: '0.0.0.0',
          port: '35729',
        )
      end

      def start_listener(server)
        options = {
          latency: 0.0,
          wait_for_delay: 0.0,
        }

        listener =
          Listen.to(@root_dir, options) do |ch_mod, ch_add, ch_del|
            handle_changes(server, [ch_mod, ch_add, ch_del].flatten)
          end
        listener.start
        listener
      end

      def handle_changes(server, chs)
        prefix_length = @root_dir.length
        paths = chs.map { |pa| pa[prefix_length..-1] }
        server.reload(paths)
      end
    end
  end
end
