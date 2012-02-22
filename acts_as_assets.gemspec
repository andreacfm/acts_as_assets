$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_assets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_assets"
  s.version     = ActsAsAssets::VERSION
  s.authors     = ["Andrea Campolonghi"]
  s.email       = ["acampolonghi@gmail.com"]
  s.homepage    = ""
  s.summary     = "Assets management"
  s.description = "Manage multiple assets related to a specific model"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  s.add_dependency "paperclip"

  s.add_dependency "ci_reporter"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "paperclip"
  s.add_development_dependency "shoulda-matchers"
end
