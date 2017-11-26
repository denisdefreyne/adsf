# frozen_string_literal: true

require 'helper'

class Adsf::Test::Server < MiniTest::Test
  include Rack::Test::Methods
  include Adsf::Test::Helpers

  def run_server(opts = {})
    opts = { root: 'output', port: 50_386 }.merge(opts)
    server = Adsf::Server.new(opts)
    thread = Thread.new do
      Thread.current.abort_on_exception = true
      server.run
    end

    # Wait for server to start up
    20.times do |i|
      begin
        Net::HTTP.get('127.0.0.1', '/', 50_386)
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET
        sleep(0.1 * 1.2**i)
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

  def test_index_xhtml_in_index_filenames__serve_index_xhtml
    File.write('output/index.xhtml', 'Hello there! Nanoc loves you! <3')
    run_server(index_filenames: ['index.xhtml']) do
      assert_equal 'Hello there! Nanoc loves you! <3', Net::HTTP.get('127.0.0.1', '/', 50_386)
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
end
