require 'rails/generators'
require 'rails/generators/migration'
require File.expand_path('../utils', __FILE__)

module AmpleAssets
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    
    desc "Copies migrations file for AmpleAssets."

    source_root File.expand_path('../templates', __FILE__)
    class << self
      include Generators::Utils
    end
    
    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end
    
    def create_migration_file
       migration_template 'migration.rb', 'db/migrate/create_ample_assets_tables.rb' rescue p $!.message
    end
    
  end
end