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
    
    def play_button(temp_object)
      attrs = identify(temp_object)
      # hardcoded for convenience
      icon_size = 500.to_f
      shortest_edge = [attrs[:width], attrs[:height]].max.to_f
      scale = (shortest_edge / 3) / icon_size
      final_icon_size = (scale * icon_size).to_i
      geometry = "#{final_icon_size}x#{final_icon_size}+#{(attrs[:width]/2)-(final_icon_size/2)}+#{(attrs[:height]/2)-(final_icon_size/2)}"
      convert(temp_object, "#{AmpleAssets::Engine.root}/app/assets/images/ample_assets/play.png -geometry #{geometry} -composite")
    end
    
  end
end