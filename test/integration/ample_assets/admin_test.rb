require 'integration_test_helper'

module AmpleAssets
  class AdminTest < ActionDispatch::IntegrationTest

    context 'The Asset Toolbar' do

      setup do
        visit '/ample_assets/files/new'
        f = ::Rails.root.join 'app/assets/images/rails.png'
        attach_file 'Attachment', f
        click_button 'Create File'
        visit new_page_path
        fill_in 'Title', :with => 'Test Page'
        click_button 'Create Page'
        click_link 'Test Page'
      end
      
      should 'allow uploads of new images' do
        # click_link 'Upload'
      end
      
      should 'display a list of recently added files' do
        click_link 'Assets'
        within('#recent-assets') do
          assert page.has_selector?('img')
        end
      end
      
    end
  
  end
end