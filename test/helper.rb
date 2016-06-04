# Load unit testing stuff
begin
  require 'minitest/autorun'
  require 'rack/test'
  require 'mocha/setup'
rescue => e
  $stderr.puts 'To run the tests, you need MiniTest, Mocha and Rack::Test.'
  raise e
end

# Load adsf
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
require 'adsf'

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
