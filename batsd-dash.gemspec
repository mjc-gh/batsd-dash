# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'batsd-dash/version'

Gem::Specification.new do |s|
  s.name        = "batsd-dash"
  s.version     = Batsd::Dash::VERSION

  s.authors     = ["mikeycgto", "btoconnor"]
  s.email       = ["mikeycgto@gmail.com", "gatzby3jr@gmail.com"]

  s.homepage    = "https://github.com/mikeycgto/batsd-dash"

  s.summary     = %q{batsd-dash}
  s.description = %q{batsd-dash - graphs and stuff for batsd. yay!}

  s.rubyforge_project = "batsd-dash"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "connection_pool"

  s.add_dependency "sinatra"
  s.add_dependency "haml"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"

  s.add_development_dependency "sinatra-contrib"
  s.add_development_dependency "compass"
end
