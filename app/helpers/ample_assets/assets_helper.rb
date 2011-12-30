module AmpleAssets
  module AssetsHelper
    
    def ample_assets
      content_tag :script, "var ample_assets = {}; ample_assets.load = true;", :type => "text/javascript"
    end
    
  end
end
