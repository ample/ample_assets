require 'test_helper'

module AmpleAssets
  class FilesControllerTest < ActionController::TestCase
    
    setup do
      # TODO: Why is this needed?
      AmpleAssets.allowed_mime_types = {
        :images => %w(image/jpeg image/png image/gif),
        :documents => %w(application/pdf),
        :other => %w(application/x-shockwave-flash)
      }
    end
    
    context 'By file type' do

      AmpleAssets.allowed_mime_types.keys.each do |key|
        should "return #{key} when requested" do
          f = File.new(:attachment_mime_type => AmpleAssets.allowed_mime_types[key].first)
          f.save(:validate => false)
          get key, { :use_route => :ample_assets, :format => :js }
          assert_response :success
          assert assigns(:current_files)
          assert_select 'li.file', :minimum => 1
        end
      end
      
    end
  
    should 'return recent assets when requested' do
      f = File.new
      f.save(:validate => false)
      get :recent, { :use_route => :ample_assets, :format => :js }
      assert_response :success
      assert assigns(:current_files)
      assert_select 'li.file', :minimum => 1
    end
    
    should 'return relevant results for a search' do
      f = File.new(:keywords => 'test')
      f.save(:validate => false)
      post :search, { :use_route => :ample_assets, :q => 'test', :format => :js }
      assert_response :success
      assert assigns(:current_files)
      assert_select 'li.file', :minimum => 1
    end
    
  end
end