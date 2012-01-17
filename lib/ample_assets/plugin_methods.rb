module AmpleAssets
  module PluginMethods
    
    def has_asset(name = 'file', options = {})
      configuration = { :foreign_key => 'file_id', :class_name => 'AmpleAssets::File' }
      configuration.update(options) if options.is_a?(Hash)
      self.belongs_to name, configuration
    end
    
  end
end