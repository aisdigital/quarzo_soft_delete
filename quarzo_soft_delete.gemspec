$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "quarzo_soft_delete/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quarzo_soft_delete"
  s.version     = QuarzoSoftDelete::VERSION
  s.authors     = ["Alessandro Tissot"]
  s.email       = ["alessandro@intelletto.com.br"]
  s.homepage    = "http://www.intelletto.com.br"
  s.summary     = "Quarzo Soft-Delete pattern implementation"
  s.description = "Quarzo Soft-Delete pattern implementation. Support to set_table_name"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activerecord", "~> 4.0"
  s.add_dependency "activesupport", "~> 4.0"
end
