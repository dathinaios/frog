# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frog/version'

Gem::Specification.new do |spec|
  spec.name          = "frog"
  spec.version       = Frog::VERSION
  spec.authors       = ["Dionysis Athinaios"]
  spec.email         = ["contact@dathin.net"]

  spec.summary       = %q{Yet another cli todo management tool. - ribbit -}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/dathinaios/frog"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.files       = ["lib/frog.rb", "lib/frog/frog_config.rb", "lib/frog/frog_state.rb", "lib/frog/frog_helpers.rb"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "thor", "~> 0.19.1"

  # spec.name        = 'frog'
  # spec.version     = '0.1.0'
  # spec.executables << 'frog'
end
