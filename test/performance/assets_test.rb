require 'test_helper'
require 'rails/performance_test_help'

class AssetsTest < ActionDispatch::PerformanceTest

  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  setup do
    @asset = AmpleAssets::File.new
    @asset.attachment_url = 'http://static.myopera.com/community/graphics/speeddials/Opera-Background-Colored-Lights.jpg'
    @asset.save
  end

  context 'A user viewing an asset' do

    should 'see output returned from image_asset helper method' do
      get "/ample_assets/files/#{@asset.id}"
    end

  end

end
