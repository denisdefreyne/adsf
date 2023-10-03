# frozen_string_literal: true

require 'helper'

class Adsf::VersionTest < Minitest::Test
  def test_has_same_version_as_adsf_live
    assert_equal Adsf::Live::VERSION, Adsf::VERSION
  end
end
