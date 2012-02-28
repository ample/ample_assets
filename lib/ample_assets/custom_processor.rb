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
      raise "Geometry of #{opts[:dimensions]} not supported for matte images" unless opts[:dimensions][/^(\d+)x(\d+)$/]
      convert(temp_object, "-gravity #{opts[:gravity]} -resize #{opts[:dimensions]}^> -crop #{opts[:dimensions]}+0+0>\! -background #{opts[:background]} -flatten")
    end
    
  end
end