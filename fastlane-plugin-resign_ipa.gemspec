# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/resign_ipa/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-resign_ipa'
  spec.version       = Fastlane::ResignIpa::VERSION
  spec.author        = 'Micah Rosales'
  spec.email         = 'mrosales@users.noreply.github.com'

  spec.summary       = 'Resign an ipa with a new provisioning profile pulled by Fastlane Match'
  spec.homepage      = 'https://github.com/mrosales/fastlane-plugin-resign_ipa'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*'] + %w[README.md LICENSE]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency('openssl')
  spec.add_dependency('plist')

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('fastlane', '>= 2.165.0')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
end
