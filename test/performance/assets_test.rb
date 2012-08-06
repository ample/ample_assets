require 'test_helper'
require 'rails/performance_test_help'

class AssetsTest < ActionDispatch::PerformanceTest

  # Refer to the documentation for all available options
  self.profile_options = { :runs => 5, :metrics => [:wall_time, :process_time], :output => 'tmp/performance', :formats => [:flat] }

  setup do
    @asset = AmpleAssets::File.create! :attachment => ::Rails.root.join('app/assets/images/rails.png')
    @page = Page.create! :title => 'Test Page', :file => @asset
  end

  context 'A user viewing an asset' do

    should 'see output returned from image_asset helper method' do
      get "/pages/#{@page.id}"
    end

  end

end
