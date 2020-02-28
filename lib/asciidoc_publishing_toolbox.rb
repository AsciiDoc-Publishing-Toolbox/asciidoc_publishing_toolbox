# frozen_string_literal: true

require 'fileutils'
require 'asciidoc_publishing_toolbox/document_configuration'
require 'asciidoc_publishing_toolbox/document'
require 'asciidoctor'
require 'asciidoctor-pdf'

# The main class
module AsciiDocPublishingToolbox
  module_function

  # Initialize a directory as a document.
  #
  # @param [Hash] opts Various options for the generation
  # @option opts [String] :dir The directory where the document will be
  #   generated
  # @option opts [Boolean] :overwrite (false) If true, it will generate the
  #   document even if the destination directory is not empty
  # @option opts [String] :title The document title
  # @option opts [Array<Hash>] :authors The document authors
  #
  # @raise [ArgumentError] if the given directory exists and is not empty and
  #   the :overwrite option was not given
  def init(opts = {})
    opts[:dir] ||= Dir.pwd
    Utilities.check_target_directory opts[:dir], opts[:overwrite]

    document_configuration = DocumentConfiguration.new opts[:title], opts[:authors]
    document_configuration.write_file opts[:dir]

    FileUtils.cp_r File.join(__dir__, 'data/.'), opts[:dir]
  end

  def build(opts = {})
    opts[:dir] ||= Dir.pwd
    document_configuration = DocumentConfiguration.load opts[:dir]
    dir = File.join(opts[:dir], 'out/')
    FileUtils.mkdir_p dir unless Dir.exist? dir
    document = Document.new document_configuration

    Asciidoctor.convert document.to_s, backend: 'html', safe: :safe, header_footer: true, to_file: File.join(dir, document.file_name + '.html')
    Asciidoctor.convert document.to_s, backend: 'pdf', safe: :safe, header_footer: true, to_file: File.join(dir, document.file_name + '.pdf'), attributes: { 'pdf-theme' => 'book', 'pdf-themesdir' => File.join(opts[:dir], 'themes'), 'media' => 'prepress' }
  end
end
