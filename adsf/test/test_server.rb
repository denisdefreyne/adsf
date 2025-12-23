# frozen_string_literal: true

require 'helper'

class Adsf::Test::Server < Minitest::Test
  include Rack::Test::Methods
  include Adsf::Test::Helpers

  def run_server(opts = {})
    opts = { root: 'output', port: 50_386 }.merge(opts)
    server = Adsf::Server.new(**opts)
    thread = Thread.new do
      Thread.current.abort_on_exception = true
      server.run
    end

    # Wait for server to start up
    20.times do |i|
      begin
        Net::HTTP.get('127.0.0.1', '/', 50_386)
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET
        sleep(0.1 * (1.2**i))
        retry
      end
      break
    end

    yield
  ensure
    server.stop
    thread.join
  end

  def setup
    super

    FileUtils.mkdir_p('output')
    FileUtils.cp("#{__dir__}/fixtures/sample.html", 'output/sample.html')
    FileUtils.cp("#{__dir__}/fixtures/sample.png", 'output/sample.png')
  end

  def test_default_config__serve_index_html
    File.write('output/index.html', 'Hello there! Nanoc loves you! <3')

    run_server do
      assert_equal 'Hello there! Nanoc loves you! <3', Net::HTTP.get('127.0.0.1', '/', 50_386)
    end
  end

  def test_default_config__serve_index_html_in_subdir
    FileUtils.mkdir_p('output/foo')
    File.write('output/foo/index.html', 'Hello there! Nanoc loves you! <3')

    run_server do
      assert_equal 'Hello there! Nanoc loves you! <3', Net::HTTP.get('127.0.0.1', '/foo/', 50_386)
    end
  end

  def test_default_config__serve_index_html_in_subdir_missing_slash
    FileUtils.mkdir_p('output/foo')
    File.write('output/foo/index.html', 'Hello there! Nanoc loves you! <3')
    run_server do
      response = Net::HTTP.get_response('127.0.0.1', '/foo', 50_386)

      assert_equal '302', response.code
      assert_equal 'http://127.0.0.1:50386/foo/', response['Location']
    end
  end

  def test_explicit_handler__serve_index_html
    File.write('output/index.html', 'Hello there! Nanoc loves you! <3')

    run_server(handler: :webrick) do
      assert_equal 'Hello there! Nanoc loves you! <3', Net::HTTP.get('127.0.0.1', '/', 50_386)
    end
  end

  def test_default_config__no_serve_index_xhtml
    File.write('output/index.xhtml', 'Hello there! Nanoc loves you! <3')

    run_server do
      assert_equal "File not found: /\n", Net::HTTP.get('127.0.0.1', '/', 50_386)
    end
  end

  def test_default_config__no_serve_wrong_index
    File.write('output/index666.html', 'Hello there! Nanoc loves you! <3')

    run_server do
      assert_equal "File not found: /\n", Net::HTTP.get('127.0.0.1', '/', 50_386)
    end
  end

  def test_default_config__no_serve_auto_extension
    File.write('output/foo.html', 'Hello there! Nanoc loves you! <3')

    run_server do
      assert_equal "File not found: /foo\n", Net::HTTP.get('127.0.0.1', '/foo', 50_386)
    end
  end

  def test_index_xhtml_in_index_filenames__serve_index_xhtml
    File.write('output/index.xhtml', 'Hello there! Nanoc loves you! <3')

    run_server(index_filenames: ['index.xhtml']) do
      assert_equal 'Hello there! Nanoc loves you! <3', Net::HTTP.get('127.0.0.1', '/', 50_386)
    end
  end

  def test_auto_extenion__serve_foo_html
    File.write('output/foo.html', 'Hello there! Nanoc loves you! <3')

    run_server(auto_extensions: 'html') do
      assert_equal 'Hello there! Nanoc loves you! <3', Net::HTTP.get('127.0.0.1', '/foo', 50_386)
    end
  end

  def test_auto_extenion__defers_to_subdir_with_index
    FileUtils.mkdir_p('output/foo')
    File.write('output/foo/index.html', 'I am a banana')
    File.write('output/foo.html', 'Did you bring your hat?')

    run_server(auto_extensions: 'html') do
      response = Net::HTTP.get_response('127.0.0.1', '/foo', 50_386)

      assert_equal '302', response.code
      assert_equal 'http://127.0.0.1:50386/foo/', response['Location']

      assert_equal 'I am a banana', Net::HTTP.get('127.0.0.1', '/foo/', 50_386)
      assert_equal 'Did you bring your hat?', Net::HTTP.get('127.0.0.1', '/foo.html', 50_386)
    end
  end

  def test_access_caching_headers
    run_server do
      response = Net::HTTP.get_response('127.0.0.1', '/', 50_386)

      assert_equal 'max-age=0, stale-if-error=0', response['Cache-Control']
    end
  end

  def test_access_control_allow_origin
    run_server do
      response = Net::HTTP.get_response('127.0.0.1', '/', 50_386)

      assert_equal '*', response['Access-Control-Allow-Origin']
    end
  end

  def test_access_control_allow_headers
    run_server do
      response = Net::HTTP.get_response('127.0.0.1', '/', 50_386)

      assert_equal 'Origin, X-Requested-With, Content-Type, Accept, Range', response['Access-Control-Allow-Headers']
    end
  end

  def test_content_type_html
    run_server do
      response = Net::HTTP.get_response('127.0.0.1', '/sample.html', 50_386)

      assert_equal 'text/html', response['Content-Type']
    end
  end

  def test_content_type_png
    run_server do
      response = Net::HTTP.get_response('127.0.0.1', '/sample.png', 50_386)

      assert_equal 'image/png', response['Content-Type']
    end
  end

  def test_non_local_interfaces
    addresses = Socket.getifaddrs.map(&:addr).select(&:ipv4?).map(&:ip_address)
    non_local_addresses = addresses - ['127.0.0.1']

    if non_local_addresses.empty?
      skip 'Need non-local network interfaces for this spec'
    end

    run_server do
      assert_raises(Errno::ECONNREFUSED) do
        Net::HTTP.get(non_local_addresses[0], '/', 50_386)
      end
    end
  end

  def run_live_server
    run_server(live: true) { yield }
  end

  def test_receives_update
    run_live_server do
      ws = Faye::WebSocket::Client.new('ws://127.0.0.1:35729/')

      sleep 0.2
      FileUtils.mkdir_p('output')
      File.write('output/index.html', 'hello thear')

      queue = SizedQueue.new(2)
      ws.on :open do |_event|
      end
      ws.on :message do |event|
        queue << event.data
      end
      ws.on :close do |_event|
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
      assert_match '/index.html', JSON.parse(messages[1])['path']
    end
  end
end
