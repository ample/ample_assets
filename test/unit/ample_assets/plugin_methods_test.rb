require 'test_helper'

class TestModel < Page
  has_asset
end

class CustomTestModel < Page
  self.abstract_class = true
  has_asset 'thing', :class_name => 'CustomFileModel'
end

module AmpleAssets
  class PluginMethodsTest < ActiveSupport::TestCase

    context 'The has_asset method' do
      
      should 'create a belongs_to association with the given model' do
        test_model = TestModel.new
        assert test_model.respond_to?(:file)
      end
      
      should 'allow a custom association name' do
        test_model = CustomTestModel.new
        assert test_model.respond_to?(:thing)
      end

    end

  end
end