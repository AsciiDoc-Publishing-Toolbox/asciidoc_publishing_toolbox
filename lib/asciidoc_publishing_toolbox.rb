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
    FileUtils.mkdir_p dir unless Dir.exist?(opts[:dir])
    opts[:overwrite] ||= false
    unless opts[:overwrite] || Dir.empty?(opts[:dir])
      raise ArgumentError, 'The given directory exists and is not empty'
    end

    document_configuration = DocumentConfiguration.new
    document_configuration.title = opts[:title]

    document_configuration.authors = opts[:authors].map { |author| DocumentConfiguration::Author.new(author[:name], author[:surname], author[:email], author[:middlename]) }

    File.open(File.join(opts[:dir], 'document.json'), 'w') do |f|
      f.write(document_configuration.to_json)
    end
  end
end
