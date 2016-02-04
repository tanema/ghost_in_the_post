$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ghost_in_the_post/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ghost_in_the_post"
  s.version     = GhostInThePost::VERSION
  s.authors     = ["Tim Anema"]
  s.email       = ["timanema@gmail.com"]
  s.homepage    = "https://github.com/tanema/ghost_in_the_post"
  s.summary     = "Using phantomjs to pre-run javascript in emails"
  s.description = "Using phantomjs to pre-run javascript in emails. This is best if you have content that uses mustache templates that you would like to reuse in your emails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.3"
  s.add_dependency "nokogiri"
 
  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "rspec-rails"
end
