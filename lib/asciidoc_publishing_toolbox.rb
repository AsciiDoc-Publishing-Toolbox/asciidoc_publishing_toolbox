# frozen_string_literal: true

require 'fileutils'
require 'document_configuration'

# The main class
class AsciiDocPublishingToolbox

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
  def self.init(opts = {})
    opts[:dir] ||= Dir.pwd
    check_target_directory opts[:dir], opts[:overwrite]

    document_configuration = DocumentConfiguration.new opts[:title], opts[:authors]

    File.open(File.join(opts[:dir], 'document.json'), 'w') do |f|
      f.write(document_configuration.to_json)
    end
  end

  # Check if a directory can be used to create a document.
  #
  # @param [String] dir The target directory. If this directory does not exists
  #   it will be created.
  # @param [Boolean] overwrite Whether or not the files in an existing target
  #   directory can be eventually overwritten by the new document
  # @raise [ArgumentError] if the given directory exists and overwrite is false.
  def self.check_target_directory(dir, overwrite = false)
    overwrite ||= false
    FileUtils.mkdir_p dir unless Dir.exist?(dir)
    return if overwrite || Dir.empty?(dir)

    raise ArgumentError, 'The given directory exists and is not empty'
  end
end
