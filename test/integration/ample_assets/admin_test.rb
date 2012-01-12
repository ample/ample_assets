require 'integration_test_helper'

module AmpleAssets
  class AdminTest < ActionDispatch::IntegrationTest

    context 'The Asset Toolbar' do

      setup do
        visit new_page_path
        fill_in 'Title', :with => 'Test Page'
        click_button 'Create Page'
        click_link 'Test Page'
      end
      
      should 'allow uploads of new images' do
        # click_link 'Upload'
      end
      
    end
  
  end
end