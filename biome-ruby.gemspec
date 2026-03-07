# frozen_string_literal: true

require_relative 'lib/biome/ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'biome-ruby'
  spec.version = Biome::Ruby::VERSION
  spec.authors = ['Michael Hebblethwaite']
  spec.email = ['32097294+michebble@users.noreply.github.com']

  spec.summary = 'A self-contained `biome` executable.'
  spec.description = 'A self-contained `biome` executable. Javascript linting and formatting without a package manager.'
  spec.homepage = 'https://github.com/michebble/biome-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/michebble/biome-ruby/'
  spec.metadata['changelog_uri'] = 'https://github.com/michebble/biome-ruby/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE.txt', 'LICENSE-DEPENDENCIES', 'README.md']
  spec.bindir = 'exe'
  spec.executables << 'biome'
  spec.require_paths = ['lib']
end
