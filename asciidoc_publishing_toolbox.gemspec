# frozen_string_literal: true

require_relative './lib/asciidoc_publishing_toolbox/version'

Gem::Specification.new do |s|
  s.name = 'asciidoc_publishing_toolbox'
  s.version = AsciiDocPublishingToolbox::VERSION
  s.license = 'GPL-3.0'
  s.summary = 'A publishing toolbox for AsciiDoc'
  s.description = 'An authoring and publishing system for the AsciiDoc markdown language'
  s.author = 'Andrea Esposito'
  s.email = 'esposito_andrea99@hotmail.com'
  s.files = Dir.glob('lib/**/*') + %w[LICENSE.md README.adoc]
  s.homepage = 'https://espositoandrea.github.io/adpt.github.io'
  s.add_runtime_dependency 'asciidoctor', '~> 2.0', '>= 2.0.10'
  s.add_runtime_dependency 'asciidoctor-pdf', '~> 1.5', '>= 1.5.3'
  s.add_runtime_dependency 'json_schemer', '~> 0.2', '>= 0.2.10'
  s.add_development_dependency 'minitest', '~> 5.14', '>= 5.14.0'
  s.executables << 'adpt'
  s.metadata = {
    'source_code_uri' => 'https://github.com/espositoandrea/asciidoc_publishing_toolbox',
    'homepage_uri' => 'https://espositoandrea.github.io/adpt.github.io',
    'bug_tracker_uri' => 'https://github.com/espositoandrea/asciidoc_publishing_toolbox/issues'
  }
end
