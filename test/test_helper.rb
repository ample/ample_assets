# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'
require 'shoulda'
require 'database_cleaner'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

DatabaseCleaner.strategy = :truncation

module AmpleAssets
  class ActiveSupport::TestCase

    def current_page
      @page ||= Page.create! :title => 'Test Page', :file_id => current_file.id
    end

    def current_file
      @file ||= File.create! :attachment => ::File.read("#{Rails.root}/app/assets/images/rails.png")
    end

  end


  class ActionController::IntegrationTest

    self.use_transactional_fixtures = false

    setup do
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
    end

  end
end
