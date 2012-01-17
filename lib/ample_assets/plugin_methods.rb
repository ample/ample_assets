module AmpleAssets
  module PluginMethods
    
    def has_assets
      self.belongs_to :file, :class_name => "AmpleAssets::File"
    end
    
  end
end