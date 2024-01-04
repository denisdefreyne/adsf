# frozen_string_literal: true

module Adsf::Test::Rack::Helpers
  def app_options
    (@app_options || {}).merge(root: '.')
  end

  def stub_app
    Rack::Files.new('.')
  end
end
