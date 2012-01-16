module AmpleAssets
  class CustomProcessor
    
    include Dragonfly::ImageMagick::Utils
    include Dragonfly::Configurable

    def matte(temp_object, args={})
      opts = {
        :background => 'transparent',
        :gravity => 'Center',
        :dimensions => '100x100'
      }.merge(args)
      convert(temp_object, "-gravity #{opts[:gravity]} -crop #{opts[:dimensions]}+0+0\! -background #{opts[:background]} -flatten")
    end

  end
end