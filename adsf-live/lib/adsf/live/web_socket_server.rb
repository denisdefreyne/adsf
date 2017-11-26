# frozen_string_literal: true

module Adsf
  module Live
    class WebSocketServer
      def initialize(host:, port:)
        @host = host
        @port = port

        @thread = start
        @sockets = []

        @stopped_waiter = SizedQueue.new(1)
      end

      def stop
        EventMachine.stop
        @stopped_waiter.pop
      end

      def reload(paths)
        paths.each do |path|
          data =
            JSON.dump(
              command: 'reload',
              path:    "#{Dir.pwd}#{path}",
            )

          @sockets.each { |ws| ws.send(data) }
        end
      end

      private

      def start
        started_waiter = SizedQueue.new(1)

        thread =
          Thread.new do
            Thread.current.abort_on_exception = true
            run(started_waiter)
            @stopped_waiter << true
          end

        started_waiter.pop

        thread
      end

      def run(started_waiter)
        EventMachine.run do
          EventMachine.defer(-> { started_waiter << true })

          EventMachine::WebSocket.run(host: @host, port: @port) do |socket|
            socket.onopen  { on_socket_connected(socket) }
            socket.onclose { on_socket_disconnected(socket) }
          end
        end
      end

      def on_socket_connected(socket)
        socket.send(
          JSON.dump(
            command:    'hello',
            protocols:  ['http://livereload.com/protocols/official-7'],
            serverName: 'nanoc-view',
          ),
        )

        @sockets << socket
      end

      def on_socket_disconnected(socket)
        @sockets.delete(socket)
      end
    end
  end
end
