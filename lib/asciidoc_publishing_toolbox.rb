# frozen_string_literal: true

require 'fileutils'
require 'asciidoctor'
require 'asciidoc_publishing_toolbox/asciidoctor-pdf-extension'
require 'asciidoc_publishing_toolbox/document_configuration'
require 'asciidoc_publishing_toolbox/document'

# The main module
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

    document_configuration = DocumentConfiguration.new title: opts[:title], authors: opts[:authors], chapters: [opts[:first_chapter]]
    document_configuration.write_file opts[:dir]

    FileUtils.cp_r File.join(__dir__, 'data/.'), opts[:dir]
    FileUtils.mkdir_p File.join(opts[:dir], 'src')
    File.write File.join(opts[:dir], 'src/colophon.adoc'), Document.default_colophon
    File.write File.join(opts[:dir], "src/#{opts[:first_chapter].downcase.gsub(' ', '-')}.adoc"), "= #{opts[:first_chapter]}"
  end

  def build(opts = {})
    opts[:dir] ||= Dir.pwd
    document_configuration = DocumentConfiguration.load opts[:dir]
    out_dir = 'out'
    if Dir.exist? File.join(opts[:dir], out_dir)
      FileUtils.rm_rf(Dir[File.join(opts[:dir], out_dir, '**/*')])
    else
      FileUtils.mkdir_p File.join(opts[:dir], out_dir)
    end
    document = Document.new document_configuration

    Asciidoctor.convert document.to_s, base_dir: opts[:dir], backend: 'html', safe: :safe, header_footer: true, to_file: File.join(out_dir, document.file_name + '.html')
    Asciidoctor.convert document.to_s, base_dir: opts[:dir], backend: 'pdf', safe: :safe, header_footer: true, to_file: File.join(out_dir, document.file_name + '.pdf'), attributes: { 'pdf-theme' => 'book', 'pdf-themesdir' => File.join(opts[:dir], 'themes'), 'media' => 'prepress' }
  end
end
