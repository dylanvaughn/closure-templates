# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "closure-templates/version"

Gem::Specification.new do |s|
  s.name        = "closure-templates"
  s.version     = Closure::Templates::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dylan Vaughn"]
  s.email       = ["dylancvaughn@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Google Closure Templates for jRuby / Rails}
  s.description = %q{Generates methods / code for server and client-side use of Google Closure Templates}

  s.add_dependency('tilt')
  s.add_development_dependency('test-unit')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
