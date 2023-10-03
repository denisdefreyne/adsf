# frozen_string_literal: true

require 'helper'

class Adsf::Live::VersionTest < Minitest::Test
  def test_has_same_version_as_adsf
    assert_equal Adsf::VERSION, Adsf::Live::VERSION
  end
end
