$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ample_assets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ample_assets"
  s.version     = AmpleAssets::VERSION
  s.authors     = ["Taylor C. MacDonald", "Bobby Uhlenbrock", "Ryan Merrill"]
  s.email       = ["developers@helloample.com"]
  s.homepage    = "http://helloample.com"
  s.summary     = "Drag and Drop Asset Management"

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.textile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "4.0.0.rc1"
  s.add_dependency "dragonfly", "~> 0.9.11"
  s.add_dependency "jquery-rails", "~> 2.2.1"
  s.add_dependency "rack-cache"
  s.add_dependency "sass-rails", "~> 4.0.0.rc1"
  s.add_dependency "coffee-rails", "~> 4.0.0"
  s.add_dependency "uglifier", ">= 1.3.0"
  s.add_dependency "therubyracer"
  s.add_dependency "will_paginate"
  s.add_dependency "acts_as_indexed"
  s.add_dependency "coffee_cup"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "turn", "~> 0.9.3"
  s.add_development_dependency "shoulda", "~> 3.5"
  s.add_development_dependency "capybara"
  s.add_development_dependency "launchy"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "selenium-webdriver", ">= 2.25.0"
  #s.add_development_dependency "rb-readline"
  s.add_development_dependency "database_cleaner"
end
