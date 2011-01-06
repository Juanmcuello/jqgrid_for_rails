# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jqgrid_for_rails/version"

Gem::Specification.new do |s|
  s.name        = "jqgrid_for_rails"
  s.version     = JqgridForRails::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Simple solution to create jqgrids easily using Rails"
  s.email       = "juanmacuello@gmail.com"
  s.homepage    = "http://github.com/Juanmcuello/jqgrid_for_rails"
  s.description = "Simple solution to create jqgrids easily using Rails"
  s.authors     = ['Juan Manuel Cuello']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("will_paginate")
end

