module AmpleAssets
  module FormHelper

    def asset_drop(object_name, method, options = {})
      render :partial => 'ample_assets/files/drop', 
        :object => options[:object],
        :locals => {
          :object_name => object_name,
          :method => method
        }
    end

  end
end