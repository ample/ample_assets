require 'integration_test_helper'

module AmpleAssets
  class AdminTest < ActionDispatch::IntegrationTest

    context 'The Asset Toolbar' do

      setup do
        visit '/ample_assets/files/new'
        attach_file 'Attachment', ::Rails.root.join('app/assets/images/rails.png')
        click_button 'Create File'
        visit new_page_path
        fill_in 'Title', :with => 'Test Page'
        click_button 'Create Page'
        click_link 'Test Page'
        click_link 'Assets'
      end

      should 'allow uploads of new files' do
        # Handled in the setup
      end

      should 'display a list of recently added files' do
        within('#recent-assets') do
          assert page.has_selector?('img')
        end
      end

      should 'show a lightbox when a thumbnail is clicked' do
        link = page.find_by_id('recent-assets').find('a').click
        assert_equal link['data-filename'], page.find('#facebox h3').value
        assert page.has_selector?('#facebox .asset-media img')
      end

      should 'allow users to search for assets by keyword' do
        assert !page.has_selector?('#asset-results img')
        fill_in 'asset-search', :with => 'rails'
        page.find_by_id('asset-search').native.send_key(:enter)
        assert page.has_selector?('#asset-results img')
      end

      should 'allow users to drag an asset into an assocation' do
        assert page.find_by_id('page_file_id').value.blank?
        image = page.find_by_id('recent-assets').find('img')
        drop = page.find('.asset-drop .droppable')
        image.drag_to(drop)
        assert !page.find_by_id('page_file_id').value.blank?
      end

      should 'allow users to remove an asset from an association' do
        assert page.find_by_id('page_file_id').value.blank?
        image = page.find_by_id('recent-assets').find('img')
        drop = page.find('.asset-drop .droppable')
        image.drag_to(drop)
        assert !page.find_by_id('page_file_id').value.blank?
        within('.asset-drop') do
          click_link('Remove')
        end
        assert page.find_by_id('page_file_id').value.blank?
      end

      should 'allow users to drag an asset into a textarea (Textile)' do
        page.execute_script("$('#body').css({width:500, height:500})")
        body = page.find_by_id('body')
        assert body.value.blank?
        image = page.find_by_id('recent-assets').find('img')
        image.drag_to(body)
        click_button 'Insert'
        assert body.value.include?('!')
      end

      should 'allow users to drag an asset into a textarea (HTML)' do
        page.execute_script("$('#body').css({width:500, height:500})")
        page.execute_script("$('#body').removeClass('textile')")
        body = page.find_by_id('body')
        assert body.value.blank?
        image = page.find_by_id('recent-assets').find('img')
        image.drag_to(body)
        click_button 'Insert'
        assert body.value.include?('src')
      end

      should 'allow users to delete an asset' do
        link = page.find_by_id('recent-assets').find('a').click
        id = link['id']
        within('#facebox') do
          click_link 'Delete'
        end
        confirm_dialog if selenium?
        within('#recent-assets') do
          assert page.has_no_selector?("#file-#{id}")
        end
      end

      should 'allow users to grab original file url from clippy inside the lightbox' do
        page.find_by_id('recent-assets').find('a').click
        assert page.has_selector?('#facebox h3 object')
      end

    end

  end
end
