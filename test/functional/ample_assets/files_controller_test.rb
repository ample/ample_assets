require 'test_helper'

module AmpleAssets
  class FilesControllerTest < ActionController::TestCase

    context 'By file type' do

      # TODO why can't functional tests default engine config values? @see ample_assets/files_controller#current_mime_types
      AmpleAssets::Configuration::DEFAULT_ALLOWED_MIME_TYPES.each do |key,value|
        should "return #{key} when requested" do
          f = File.new(:attachment_mime_type => value.first)
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
