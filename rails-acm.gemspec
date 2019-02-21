
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails/acm/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-acm"
  spec.version       = Rails::Acm::VERSION
  spec.authors       = ["Matt Rohrer"]
  spec.email         = ["matt@prognostikos.com"]

  spec.summary       = "An Automated Certificate Manager as a Rails Engine"
  spec.homepage      = "https://github.com/rails-acm/rails-acm"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/rails-acm/rails-acm"
    spec.metadata["changelog_uri"] = "https://github.com/rails-acm/rails-acm/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "acme-client", ">= 2.0.5"
  spec.add_dependency "attr_encrypted"
  spec.add_dependency "aws-sdk-route53"
  spec.add_dependency "platform-api"
  spec.add_dependency "railties"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
end
