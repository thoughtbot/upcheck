# frozen_string_literal: true

require_relative "lib/upcheck/version"

Gem::Specification.new do |spec|
  spec.name = "upcheck"
  spec.version = Upcheck::VERSION
  spec.authors = ["Matheus Richard"]
  spec.email = ["matheusrichardt@gmail.com"]

  spec.summary = "Ruby client for checking the status of third-party services."
  spec.description = <<~DESC
    Upcheck is a zero-dependency Ruby client for checking the public status of
    the services your app depends on: whether a provider is operational, which
    components are degraded, and what incidents or scheduled maintenances are
    active. Use it to show degradation banners, fail fast in background jobs,
    or switch to a fallback provider when a dependency is down.
  DESC
  spec.homepage = "https://github.com/MatheusRich/upcheck"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
