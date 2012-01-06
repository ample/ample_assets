$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ample_assets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ample_assets"
  s.version     = AmpleAssets::VERSION
  s.authors     = ["Taylor C. MacDonald"]
  s.email       = ["taylor@helloample.com"]
  s.homepage    = "http://helloample.com"
  s.summary     = "Drag and Drop Asset Management"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.3"
  s.add_dependency "dragonfly", "~> 0.9.8"
  s.add_dependency "jquery-rails"
  s.add_dependency "rack-cache"
  s.add_dependency "sass-rails", "~> 3.1.5" 
  s.add_dependency "coffee-rails", "~> 3.1.1"
  s.add_dependency "uglifier"
  s.add_dependency "compass", "~> 0.12.alpha.2"
  s.add_dependency "therubyracer"
  s.add_dependency "will_paginate"
  
  s.add_development_dependency "sqlite3"
end
