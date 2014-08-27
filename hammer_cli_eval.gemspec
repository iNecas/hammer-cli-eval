$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_eval/version"

Gem::Specification.new do |s|

  s.name = "hammer_cli_eval"
  s.authors = ["inecas@redhat.com"]
  s.version = HammerCLIEval.version.dup
  s.platform = Gem::Platform::RUBY
  s.summary = %q{Ruby console to the hammer world}

  s.files = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '>= 0.0.6'
  s.add_dependency 'pry'
end
