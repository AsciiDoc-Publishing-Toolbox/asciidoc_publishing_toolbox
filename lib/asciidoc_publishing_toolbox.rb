# frozen_string_literal: true

require 'fileutils'
require 'asciidoctor'
require 'asciidoc_publishing_toolbox/asciidoctor-pdf-extension'
require 'asciidoc_publishing_toolbox/document/document_configuration'
require 'asciidoc_publishing_toolbox/document/document'
require 'asciidoc_publishing_toolbox/utilities'

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

    document_configuration = Document::DocumentConfiguration.new title: opts[:title], authors: opts[:authors], chapters: [{title: opts[:first_chapter]}],lang: opts[:lang], copyright: opts[:copyright]
    document_configuration.write_file opts[:dir]

    FileUtils.cp_r File.join(__dir__, 'data/.'), opts[:dir]
    FileUtils.mkdir_p File.join(opts[:dir], 'src')
    File.write File.join(opts[:dir], "src/#{opts[:first_chapter].downcase.gsub(' ', '-')}.adoc"), "= #{opts[:first_chapter]}"
  end

  def build(opts = {})
    opts[:dir] ||= Dir.pwd
    document_configuration = Document::DocumentConfiguration.load opts[:dir]
    out_dir = 'out'
    if Dir.exist? File.join(opts[:dir], out_dir)
      FileUtils.rm_rf(Dir[File.join(opts[:dir], out_dir, '**/*')])
    else
      FileUtils.mkdir_p File.join(opts[:dir], out_dir)
    end
    document = Document.new document_configuration

    Asciidoctor.convert document.to_s, base_dir: opts[:dir], backend: 'html', safe: :safe, header_footer: true, to_file: File.join(out_dir, document.file_name + '.html')
    Asciidoctor.convert document.to_s, base_dir: opts[:dir], backend: 'pdf', safe: :safe, header_footer: true, to_file: File.join(out_dir, document.file_name + '.pdf'), attributes: {'pdf-theme' => 'book', 'pdf-themesdir' => File.join(opts[:dir], 'themes'), 'media' => 'prepress'}
  end

  def new_chapter(title, opts = {})
    opts[:dir] ||= Dir.pwd
    opts[:is_part] ||= false
    unless Document::DocumentConfiguration.document? opts[:dir]
      raise ArgumentError, 'The directory is not a document. The directory must be a valid document'
    end

    doc = Document::DocumentConfiguration.load Pathname.new(opts[:dir])
    doc.add_chapter(title, opts[:is_part])
    File.write File.join(opts[:dir], 'src', "#{title.downcase.gsub(' ', '-')}.adoc"),
               "= #{title}"
    doc.write_file opts[:dir]
  end

  # Rename an existing chapter
  # @param [Integer] chapter The chapter number.
  # @param [String] new_title The new title.
  def rename_chapter(chapter, new_title, opts = {})
    opts[:dir] ||= Dir.pwd
    opts[:is_part] ||= false
    unless Document::DocumentConfiguration.document? opts[:dir]
      raise ArgumentError, 'The directory is not a document. The directory must be a valid document'
    end

    doc = Document::DocumentConfiguration.load Pathname.new(opts[:dir])
    old_file = "#{doc.chapters[chapter][:title].downcase.gsub(' ', '-')}.adoc"
    doc.rename_chapter(chapter, new_title)
    File.rename File.join(opts[:dir], 'src', old_file), File.join(opts[:dir], 'src', new_title.downcase.gsub(' ', ''))
    # TODO: FIX AND REMOVE
    puts 'WARNING: You must change the title in the document.'
    doc.write_file opts[:dir]
  end
end
