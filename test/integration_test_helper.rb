require 'test_helper'
require 'capybara/rails'

class ActionController::IntegrationTest
  
  include Capybara::DSL
  
  Capybara.default_driver = :selenium
  Capybara.default_wait_time = 10
  
  def confirm_dialog
    a = page.driver.browser.switch_to.alert
    if a.text == 'OK'
      a.dismiss
    else
      a.accept
    end
  end
  
  def selenium?
    Capybara.default_driver == :selenium
  end
  
end