module AmpleAssets
  module FormBuilder

    def asset_drop(method, options = {})
      options.merge!(:object => @object.send(method.to_s.gsub(/_id$/, '')))
      @template.asset_drop(@object_name, method, options)
    end

  end
end