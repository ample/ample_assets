# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'
require 'shoulda'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module AmpleAssets
  class ActiveSupport::TestCase
    
    def current_page
      @page ||= Page.create! :title => 'Test Page', :file_id => current_file.id
    end

    def current_file
      @file ||= File.create! :attachment => ::File.read("#{Rails.root}/app/assets/images/rails.png")
    end
    
  end
end