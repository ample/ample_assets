require 'test_helper'

module AmpleAssets
  class ConfigurationTest < ActiveSupport::TestCase
  
    context 'The Configuration' do
    
      context 'defaults' do
      
        AmpleAssets::Configuration::VALID_OPTIONS_KEYS.each do |key|
          should "be returned for #{key}" do
            AmpleAssets.send(key) == eval("AmpleAssets::Configuration::DEFAULT_#{key.upcase}")
          end
        
        end
      
      end
    
      context 'via a configure block' do
      
        AmpleAssets::Configuration::VALID_OPTIONS_KEYS.each do |key|
          should "set the #{key}" do
            AmpleAssets.configure do |config|
              config.send("#{key}=", key)
              assert AmpleAssets.send(key) == key
            end
          end
        end
     
      end
    
    end
  
  end
end