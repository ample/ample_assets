module AmpleAssets
  require 'ample_assets/engine' if defined?(Rails)
  class << self

    # hooks AmpleAssets::ViewHelpers into ActionView::Base
    def enable_actionpack
      return if ActionView::Base.instance_methods.include? :asset_drop
      require 'ample_assets/view_helper'
      require 'ample_assets/form_helper'
      require 'ample_assets/form_builder'
      ActionView::Base.send :include, ViewHelper
      ActionView::Base.send :include, AmpleAssets::FormHelper
      ActionView::Helpers::FormBuilder.send :include, AmpleAssets::FormBuilder
    end

  end
end

if defined? Rails
  AmpleAssets.enable_actionpack if defined? ActionController
end