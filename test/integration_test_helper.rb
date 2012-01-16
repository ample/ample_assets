require 'test_helper'
require 'capybara/rails'

class ActionController::IntegrationTest
  
  include Capybara::DSL
  
  Capybara.default_driver = :selenium
  Capybara.default_wait_time = 10
  
end