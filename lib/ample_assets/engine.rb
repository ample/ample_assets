require 'ample_assets'
require 'rails'
require 'rack/cache'
require 'acts_as_indexed'
require 'dragonfly'
require 'ample_assets/custom_processor'
require 'will_paginate'
require 'will_paginate/array'

module AmpleAssets
  class Engine < Rails::Engine
    isolate_namespace AmpleAssets

    initializer 'ample_assets: configure rack/cache' do |app|
      app.middleware.insert 0, ::Rack::Cache, {
        :verbose     => false,
        :metastore   => "file:#{Rails.root}/tmp/dragonfly/cache/meta",
        :entitystore => "file:#{Rails.root}/tmp/dragonfly/cache/body"
      }
    end
    
    initializer 'ample_assets: configure dragonfly' do |app|
      dfly = Dragonfly[:images]
      dfly.define_macro ActiveRecord::Base, :image_accessor
      dfly.register_mime_type(:swf, 'application/x-shockwave-flash')
      dfly.configure_with(:imagemagick)
      dfly.configure_with(:rails)
      dfly.processor.register(CustomProcessor)
      app.middleware.insert_after ::Rack::Cache, ::Dragonfly::Middleware, :images
    end
    
    initializer 'ample_assets: cleanup configuration' do |app|
      AmpleAssets.mount_at += '/'  unless AmpleAssets.mount_at.last == '/'
    end
    
  end
end
