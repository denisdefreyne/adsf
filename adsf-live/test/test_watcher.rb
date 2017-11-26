# frozen_string_literal: true

require 'helper'

class Adsf::Live::WatcherTest < MiniTest::Test
  include Rack::Test::Methods
  include Adsf::Test::Helpers

  def run_watcher(root_dir: nil)
    FileUtils.mkdir_p('public')
    root_dir ||= File.expand_path('public')
    watcher = Adsf::Live::Watcher.new(root_dir: root_dir)

    begin
      watcher.start
      yield
    ensure
      watcher.stop
    end
  end

  def test_receives_hello
    run_watcher do
      ws = Faye::WebSocket::Client.new('ws://127.0.0.1:35729/')

      queue = SizedQueue.new(2)
      ws.on :open do |_event|
      end
      ws.on :message do |event|
        queue << event.data
      end
      ws.on :close do |_event|
      end

      messages = []
      1.times { messages << queue.pop }

      expected_hello_data = {
        'command' => 'hello',
        'protocols' => ['http://livereload.com/protocols/official-7'],
        'serverName' => 'nanoc-view',
      }
      assert_equal expected_hello_data, JSON.parse(messages[0])
    end
  end

  def test_requires_absolute_path
    assert_raises(ArgumentError, 'Watcher#initialize: The root_path argument must be an absolute path') do
      run_watcher(root_dir: 'public') {}
    end
  end

  def test_receives_update
    run_watcher do
      ws = Faye::WebSocket::Client.new('ws://127.0.0.1:35729/')

      queue = SizedQueue.new(2)
      ws.on :open do |_event|
        sleep 0.5
        File.write('public/index.html', 'hello thear')
      end
      ws.on :message do |event|
        queue << event.data
      end
      ws.on :close do |event|
        raise "unexpected close: #{event.code}" unless event.code == 1006
      end

      messages = []
      2.times { messages << queue.pop }

      expected_hello_data = {
        'command' => 'hello',
        'protocols' => ['http://livereload.com/protocols/official-7'],
        'serverName' => 'nanoc-view',
      }

      assert_equal expected_hello_data, JSON.parse(messages[0])

      assert_equal 'reload', JSON.parse(messages[1])['command']
      assert_match %r{adsf(-live)?/tmp/index\.html$}, JSON.parse(messages[1])['path']
    end
  end
end
