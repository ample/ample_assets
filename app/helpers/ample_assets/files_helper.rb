module AmpleAssets
  module FilesHelper
    
    def ample_assets
      script = "var ample_assets = {}; ample_assets.load = true; "
      script += "ample_assets.mount_at = '#{AmpleAssets::Engine.config.mount_at}'; "
      script += ample_assets_pages
      content_tag :script, script, :type => "text/javascript"
    end
    
    def ample_assets_pages
      "\nample_assets.pages = [
        { id: 'recent-assets', title: 'Recently Viewed', url: '#{root_path}', panels: true },
        { id: 'image-assets', title: 'Images' },
        { id: 'document-assets', title: 'Documents' },
        { id: 'upload', title: 'Upload', url: '#{new_file_path}' }
      ];".gsub(/\s+/, "")
    end
    
  end
end
