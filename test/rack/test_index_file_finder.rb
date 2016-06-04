require 'test/helper'

class Adsf::Test::Rack::IndexFileFinder < MiniTest::Test
  include Rack::Test::Methods
  include Adsf::Test::Helpers

  def app
    ::Adsf::Rack::IndexFileFinder.new(
      stub_app,
      (@options || {}).merge(root: '.')
    )
  end

  def stub_app
    Rack::File.new('.')
  end

  def test_get_file
    # Create test file
    File.write('motto.txt', 'More human than human')

    # Request test file
    get '/motto.txt'
    assert last_response.ok?
    assert_equal 'More human than human', last_response.body
  end

  def test_get_dir_without_index_file_without_slash
    # Create test directory
    FileUtils.mkdir('replicants')

    # Request test directory
    get '/replicants'
    assert last_response.redirect?
    assert_equal '/replicants/', last_response.location
  end

  def test_get_dir_without_index_file_with_slash
    # Create test directory
    FileUtils.mkdir('replicants')

    # Request test directory
    get '/replicants/'
    assert last_response.not_found?
  end

  def test_get_dir_with_index_file_without_slash
    # Create test directory
    FileUtils.mkdir('replicants')

    # Create test file
    File.write('replicants/index.txt', 'Leon, Roy, Pris, Zhora, etc.')

    # Request test directory
    get '/replicants'
    assert last_response.redirect?
    assert_equal '/replicants/', last_response.location
  end

  def test_get_dir_with_index_file_with_slash
    # Create test directory
    FileUtils.mkdir('replicants')

    # Create test file
    File.write('replicants/index.html', 'Leon, Roy, Pris, Zhora, etc.')

    # Request test directory
    get '/replicants/'
    assert last_response.ok?
    assert_equal 'Leon, Roy, Pris, Zhora, etc.', last_response.body
  end

  def test_get_dir_with_custom_index_file
    @options = { index_filenames: ['list.xml'] }

    # Create test directory
    FileUtils.mkdir('replicants')

    # Create test file
    File.write('replicants/list.xml', 'Leon, Roy, Pris, Zhora, etc.')

    # Request test directory
    get '/replicants/'
    assert last_response.ok?
    assert_equal 'Leon, Roy, Pris, Zhora, etc.', last_response.body
  end

  def test_get_dir_without_slash_with_escaped_url
    # Create test directory
    FileUtils.mkdir('animal replicants')

    # Request test directory
    get '/animal%20replicants'
    assert last_response.redirect?
    assert_equal '/animal%20replicants/', last_response.location
  end
end
