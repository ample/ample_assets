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
    validates_property :mime_type, :of => :attachment, :in => AmpleAssets.allowed_mime_types.collect{ |a| a[1] }.flatten

    ###---------------------------------------------------- Instance Methods
    
    def is_swf?
      attachment_mime_type == 'application/x-shockwave-flash'
    end
    
    def is_image?
      AmpleAssets.allowed_mime_types[:images].include?(attachment_mime_type)
    end
    
    def is_doc?
      AmpleAssets.allowed_mime_types[:documents].include?(attachment_mime_type)
    end
    
    def thumbnail
      attachment.process(:matte, :dimensions => '75x75', :background => 'white').url if is_image?
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
        size: '#{attachment.width}x#{attachment.height}',
        sizes: { 
          tn: '#{thumbnail}', 
          md: '#{medium}' 
        }
      }")
    end
    
  end
end
