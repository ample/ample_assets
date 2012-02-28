module AmpleAssets
  class DeviseConstraint
    
    def self.matches?(request)
      request.env['warden'].present? ? request.env['warden'].authenticate! : true
    end
    
  end
end