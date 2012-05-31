# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "batsd-dash"
  s.version     = "0.0.1"
  s.authors     = ["mikeycgto"]
  s.email       = ["mikeycgto@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{batsd-dash}
  s.description = %q{batsd-dash - graphs and stuff from batds. yay.}

  s.rubyforge_project = "batsd-dash"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency "sinatra"
  s.add_dependency "sinatra-contrib"
  s.add_dependency "sinatra-synchrony"

  s.add_dependency "haml"
  s.add_dependency "yajl-ruby"

  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "thin"
	s.add_development_dependency "minitest"
  s.add_development_dependency "turn"
end
