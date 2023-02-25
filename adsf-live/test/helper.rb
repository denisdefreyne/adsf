# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
SimpleCov.command_name 'test:adsf-live'

require 'faye/websocket'
require 'rack/test'
require 'minitest/autorun'
require 'net/http'
require 'rack'

require 'adsf/live'

module Adsf::Test
  module Rack; end
end

module Adsf::Test::Helpers
  def setup
    # Clean up
    GC.start

    # Go quiet
    $stdout = StringIO.new
    $stderr = StringIO.new

    # Enter tmp
    FileUtils.mkdir_p('tmp')
    FileUtils.cd('tmp')
  end

  def teardown
    # Exit tmp
    FileUtils.cd('..')
    FileUtils.rm_rf('tmp')

    # Go unquiet
    $stdout = STDOUT
    $stderr = STDERR
  end
end
