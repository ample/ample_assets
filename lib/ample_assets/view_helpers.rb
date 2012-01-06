module AmpleAssets
  module ViewHelpers
    
    def assets_toolbar(pages = nil)
      pages = ample_assets_pages if pages.nil?
      script = "var ample_assets = {}; ample_assets.load = true; "
      script += "ample_assets.mount_at = '#{AmpleAssets::Engine.config.mount_at}'; "
      script += pages
      content_tag :script, script, :type => "text/javascript"
    end
    
    # TODO: move this to YAML
    def ample_assets_pages
      "\nample_assets.pages = [
        { id: 'recent-assets', title: 'Recently Viewed', url: '#{ample_assets.recent_files_path}', panels: true, data_type: 'json' },
        { id: 'image-assets', title: 'Images', url: '#{ample_assets.files_path}', panels: true, data_type: 'json' },
        { id: 'document-assets', title: 'Documents' },
        { id: 'upload', title: 'Upload', url: '#{ample_assets.new_file_path}' }
      ];".gsub(/\s+/, "")
    end
    
  end
end