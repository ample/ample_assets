require 'dragonfly'

module AmpleAssets
  class File < ActiveRecord::Base
    
    IMAGE_MIME_TYPES = %w(image/jpeg image/png image/gif)
    SWF_MIME_TYPES = %w(application/x-shockwave-flash)
    DOC_MIME_TYPES = %w(application/pdf)
    
    ###---------------------------------------------------- Plugins
    
    image_accessor :attachment
    self.per_page = 20
    acts_as_indexed :fields => [:keywords]
    
    ###---------------------------------------------------- Scopes
    
    scope :recent, order('updated_at DESC')
    
    ###---------------------------------------------------- Validations
    
    validates_presence_of :attachment
    validates_property :mime_type, :of => :attachment, :in => IMAGE_MIME_TYPES + SWF_MIME_TYPES + DOC_MIME_TYPES
    
    ###---------------------------------------------------- Instance Methods
    
    def is_swf?
      SWF_MIME_TYPES.include?(attachment_mime_type)
    end
    
    def is_image?
      IMAGE_MIME_TYPES.include?(attachment_mime_type)
    end
    
    def thumbnail
      attachment.thumb('75x75#').url if is_image?
    end
    
    def medium
      attachment.thumb('500x>').url if is_image?
    end
    
    def json
      eval("{ 
        id: '#{id}', 
        uid: '#{attachment_uid}',
        document: '#{is_doc?}',
        orientation: '#{orientation}',
        sizes: { 
          tn: '#{thumbnail}', 
          md: '#{medium}' 
        }
      }")
    end
    
    def is_doc?
      (DOC_MIME_TYPES + SWF_MIME_TYPES).include?(attachment_mime_type)
    end
    
    def orientation
      attachment.portrait? ? 'portrait' : 'landscape'
    end
    
  end
end
