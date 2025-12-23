# frozen_string_literal: true

require 'helper'

class Adsf::ManifestTest < Minitest::Test
  def test_has_correct_manifest
    manifest_lines =
      File.readlines('adsf.manifest').map(&:chomp).reject(&:empty?)

    gemspec = eval(File.read('adsf.gemspec'), binding, 'adsf.gemspec')

    gemspec_lines = gemspec.files

    missing_from_manifest = gemspec_lines - manifest_lines

    assert_empty missing_from_manifest

    extra_in_manifest = manifest_lines - gemspec_lines

    assert_empty extra_in_manifest
  end
end
