module AmpleAssets
  module FilesHelper
    
    def ample_assets
      content_tag :script, "var ample_assets = {}; ample_assets.load = true; #{ample_assets_pages}", :type => "text/javascript"
    end
    
    def ample_assets_pages
      "\nample_assets.pages = [
        { id: 'recent-assets', title: 'Recently Viewed', url: '#{root_path}' },
        { id: 'image-assets', title: 'Images' },
        { id: 'document-assets', title: 'Documents' },
        { id: 'upload', title: 'Upload', url: '#{new_file_path}' }
      ];"
    end
    
  end
end
