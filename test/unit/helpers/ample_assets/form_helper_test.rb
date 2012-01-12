require 'test_helper'

module AmpleAssets
  class FormHelperTest < ActionView::TestCase
    
    context 'The asset_drop method' do
      
      setup do
        render :text => asset_drop(:f, :g)
      end

      should 'create a hidden field' do
        assert_select 'input[type=hidden]'
      end

      should 'be named according to the object and attribute' do
        assert_select 'input#f_g'
      end
      
    end
  
  end
end