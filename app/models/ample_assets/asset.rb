require 'dragonfly'

module AmpleAssets
  class Asset < ActiveRecord::Base
    
    IMAGE_MIME_TYPES = %w(image/jpeg image/png image/gif)
    SWF_MIME_TYPES = %w(application/x-shockwave-flash)
    
    ###---------------------------------------------------- Plugins
    
    image_accessor :attachment
    
    ###---------------------------------------------------- Scopes
    
    scope :recent, order('created_at DESC')
    
    ###---------------------------------------------------- Validations
    
    validates_presence_of :attachment
    validates_property :mime_type, :of => :attachment, :in => IMAGE_MIME_TYPES + %w(application/pdf application/x-shockwave-flash)
    
    ###---------------------------------------------------- Instance Methods
    
    def is_swf?
      SWF_MIME_TYPES.include?(attachment_mime_type)
    end
    
    def is_image?
      IMAGE_MIME_TYPES.include?(attachment_mime_type)
    end
    
  end
end
