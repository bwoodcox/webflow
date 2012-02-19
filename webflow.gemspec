# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "webflow/version"

Gem::Specification.new do |s|
  s.name        = "webflow"
  s.version     = WebFlow::VERSION
  s.authors     = [ "Bryan Woodcox", "Corey Woodcox" ]
  s.email       = ["bryan.woodcox@gmail.com", "corey.woodcox@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Tool to build guided wizards in a Rails application}
  s.description = %q{Tool to build guided wizards in a Rails application}

  s.rubyforge_project = "webflow"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
