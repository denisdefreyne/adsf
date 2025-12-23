# frozen_string_literal: true

require 'helper'
require 'rack/helper'

class Adsf::Test::Rack::AutoFileExtensions < Minitest::Test
  include Rack::Test::Methods
  include Adsf::Test::Helpers
  include Adsf::Test::Rack::Helpers

  def app
    ::Adsf::Rack::AutoFileExtensions.new(
      stub_app,
      **app_options,
    )
  end

  def test_no_auto_extensions
    @app_options = { extensions: [] }

    # Create test file
    File.write('winner.blatz', 'particle')

    # Request test file
    get '/winner.blatz'

    assert_predicate last_response, :ok?
    assert_equal 'particle', last_response.body
  end

  def test_applies_single_auto_extension
    @app_options = { extensions: 'blatz' }

    # Create test file
    File.write('winner.blatz', 'particle')

    # Request test file
    get '/winner'

    assert_predicate last_response, :ok?
    assert_equal 'particle', last_response.body
  end

  def test_finds_auto_extension_later_in_list
    @app_options = { extensions: %w[blatz flerg biffle] }

    # Create test file
    File.write('winner.flerg', 'universe')

    # Request test file
    get '/winner'

    assert_predicate last_response, :ok?
    assert_equal 'universe', last_response.body
  end

  def test_earlier_extensions_take_precedence
    @app_options = { extensions: %w[blatz flerg biffle] }

    # Create test file
    File.write('winner.blatz', 'universe')
    File.write('winner.flerg', 'particle')
    File.write('winner.biffle', 'person')

    # Request test file
    get '/winner'

    assert_predicate last_response, :ok?
    assert_equal 'universe', last_response.body
  end

  def test_no_extension_takes_precedence
    @app_options = { extensions: %w[blatz flerg biffle] }

    # Create test file
    File.write('winner', 'triangle')
    File.write('winner.blatz', 'particle')
    File.write('winner.biffle', 'person')

    # Request test file
    get '/winner'

    assert_predicate last_response, :ok?
    assert_equal 'triangle', last_response.body
  end

  def test_not_found
    @app_options = { extensions: %w[blatz flerg biffle] }

    # No files to serve

    # Request test file
    get '/winner'

    assert_predicate last_response, :not_found?
  end
end
