module AmpleAssets
  module PluginMethods
    
    def has_asset(name = :file, options = {})
      configuration = { :foreign_key => "#{name}_id", :class_name => 'AmpleAssets::File' }
      configuration.update(options) if options.is_a?(Hash)
      self.belongs_to name.to_sym, configuration
    end
    
  end
end
