require 'test_helper'

module AmpleAssets
  class FileTest < ActiveSupport::TestCase
    
    should 'create keywords based on the uploaded filename' do
      file = File.new :attachment_url => 'http://www.google.com/intl/en_com/images/srpr/logo3w.png'
      file.save
      file.reload
      assert file.keywords.include?('Logo3w')
    end
    
  end
end