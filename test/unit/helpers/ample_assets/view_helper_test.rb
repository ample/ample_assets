require 'test_helper'

module AmpleAssets
  class ViewHelperTest < ActionView::TestCase
    
    context 'The assets_toolbar method' do
      
      setup do
        # TODO: Why is this needed?
        AmpleAssets.mount_at = '/ample_assets/'
        AmpleAssets.tabs = [
          { :id => 'recent-assets', :title => 'Recently Viewed', :url => '/ample_assets/files/recent', :panels => true, :data_type => 'json' },
          { :id => 'image-assets', :title => 'Images', :url => '/ample_assets/files/images', :panels => true, :data_type => 'json' },
          { :id => 'document-assets', :title => 'Documents', :url => '/ample_assets/files/documents', :panels => true, :data_type => 'json' },
          { :id => 'upload', :title => 'Upload', :url => '/ample_assets/files/new' }
        ]
        render :text => assets_toolbar
      end
    
      should 'set the mount_at path' do
        assert_select('script', :html => /mount_at = '#{AmpleAssets.mount_at.gsub('/', '\/')}'/)
      end
      
      should 'set the tabs based on configuration options' do
        AmpleAssets.tabs.each do |tab|
          assert_select('script', :html => /#{tab[:url].gsub('/', '\/')}/)
        end
      end
      
      should 'not be html escaped' do
        assert_select('script', :html => /&quot;/, :count => 0)
      end
    
    end
    
    context 'The image_asset method' do

      context 'without args' do

        setup do
          render :text => image_asset(current_page)
        end
        
        should 'not require dimensions to be set' do
          assert_select("img[width=50]")
          assert_select("img[height=64]")
        end

      end
      
      context 'with some args' do
        
        setup do
          render :text => image_asset(current_page, { :size => false })
        end
        
        should 'have no dimensions if size is false' do
          assert_select("img[width]", false)
          assert_select("img[height]", false)
        end

      end
      
      context 'with args' do
        
        setup do
          render :text => image_asset(current_page, {
                            :dimensions => '50x50#', 
                            :style => 'border: 1px solid;', 
                            :class => "some-selector", 
                            :title => current_page.title,
                            :link => 'http://yahoo.com',
                            :video => true,
                            :video_dimensions => '1x1',
                            :encode => :jpg })
        end
        
        should 'output an img tag' do
          assert_select("img")
        end
        
        should 'have an alt attribute' do
          assert_select("img[alt]")
        end
        
        should 'not contain invalid attributes' do
          assert_select("img[dimensions]", false)
          assert_select("img[encode]", false)
          assert_select("img[object]", false)
          assert_select("img[video_dimensions]", false)
        end
        
        should 'have a title attribute if one is defined' do
          assert_select("img[title]")
        end

        should 'have a style attribute if one is defined' do
          assert_select("img[style*=border]")
        end

        should 'have a class attribute if one is defined' do
          assert_select("img[class*=some-selector]")
        end

        should 'have width and height attributes if dimensions are defined' do
          assert_select("img[width=50]")
          assert_select("img[height=50]")
        end

        should 'be wrapped in a link tag if one is defined' do
          assert_select("a[href=http://yahoo.com]")
        end

        should 'output facebox specific attrs if :video is true' do
          assert_select("a[rel=facebox]")
          assert_select("a[rev=iframe|1x1]")
        end

        should 'be encoded properly if an encoding is defined' do
          assert_select("img[src*=jpg]")
        end
        
      end
      
    end
    
  end
end