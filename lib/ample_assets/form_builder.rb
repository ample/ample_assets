module AmpleAssets
  module FormBuilder

    def asset_drop(method, options = {})
      if options.delete(:serialized)
        begin 
          object = AmpleAssets::File.find(options[:value])
        rescue ActiveRecord::RecordNotFound
          object = @object
        end
        options.merge!(:object => object)
      else
        options.merge!(:object => @object.send(method.to_s.gsub(/_id$/, '')))
      end
      @template.asset_drop(@object_name, method, options)
    end

  end
end