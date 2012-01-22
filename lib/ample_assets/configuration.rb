module AmpleAssets
  # Defines constants and methods related to configuration
  module Configuration
    
    # An array of valid keys in the options hash when configuring
    VALID_OPTIONS_KEYS = [
      :mount_at,
      :tabs,
      :allowed_mime_types].freeze
     
    # Route path prefix
    DEFAULT_MOUNT_AT = '/ample_assets/'
    
    # Tabs available in the Assets Toolbar
    DEFAULT_TABS = [
      { :id => 'recent-assets', :title => 'Recently Viewed', :url => '/ample_assets/files/recent', :panels => true, :data_type => 'json' },
      { :id => 'image-assets', :title => 'Images', :url => '/ample_assets/files/images', :panels => true, :data_type => 'json' },
      { :id => 'document-assets', :title => 'Documents', :url => '/ample_assets/files/documents', :panels => true, :data_type => 'json' },
      { :id => 'upload', :title => 'Upload', :url => '/ample_assets/files/new' }
    ]
    
    # File types available for upload
    DEFAULT_ALLOWED_MIME_TYPES = {
      :images => %w(image/jpeg image/png image/gif),
      :documents => %w(application/pdf),
      :other => %w(application/x-shockwave-flash)
    }
    
    # @private
    attr_accessor *VALID_OPTIONS_KEYS
    
    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      options = {}
      VALID_OPTIONS_KEYS.each{|k| options[k] = send(k)}
      options
    end

    # Reset all configuration options to defaults
    def reset
      self.mount_at = DEFAULT_MOUNT_AT
      self.tabs = DEFAULT_TABS
      self.allowed_mime_types = DEFAULT_ALLOWED_MIME_TYPES
      self
    end
    
  end
end