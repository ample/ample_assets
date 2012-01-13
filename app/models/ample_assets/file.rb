require 'dragonfly'

module AmpleAssets
  class File < ActiveRecord::Base
    
    ###---------------------------------------------------- Plugins
    
    image_accessor :attachment do
        after_assign { |a| self.keywords = a.name.gsub(/[^a-zA-Z0-9]/,' ').humanize unless a.name.nil? }
    end
    
    self.per_page = 20
    acts_as_indexed :fields => [:keywords]
    
    ###---------------------------------------------------- Scopes
    
    scope :recent, order('updated_at DESC')
    
    ###---------------------------------------------------- Validations
    
    validates_presence_of :attachment
    validates_property :mime_type, :of => :attachment, :in => AmpleAssets::Engine.config.allowed_mime_types.collect{ |a| a[1] }.flatten

    ###---------------------------------------------------- Instance Methods
    
    def is_swf?
      attachment_mime_type == 'application/x-shockwave-flash'
    end
    
    def is_image?
      AmpleAssets::Engine.config.allowed_mime_types[:images].include?(attachment_mime_type)
    end
    
    def is_doc?
      AmpleAssets::Engine.config.allowed_mime_types[:documents].include?(attachment_mime_type)
    end
    
    def thumbnail
      attachment.thumb('75x75#').url if is_image?
    end
    
    def medium
      attachment.thumb('500x>').url if is_image?
    end
    
    def orientation
      attachment.portrait? ? 'portrait' : 'landscape'
    end
    
    def json
      eval("{ 
        id: '#{id}', 
        uid: '#{attachment_uid}',
        document: '#{is_doc?}',
        orientation: '#{orientation}',
        url: '#{attachment.url}',
        sizes: { 
          tn: '#{thumbnail}', 
          md: '#{medium}' 
        }
      }")
    end
    
  end
end
