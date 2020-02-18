require 'fileutils'
require 'document_configuration'

# The main class
class AsciiDocPublishingToolbox

  # Returns an 'hello world' message
  #
  # @return [String] 'hello world'
  def self.init(dir = Dir.pwd, options = {})
    FileUtils.mkdir_p dir unless Dir.exist?(dir)

    unless options[:overwrite] || Dir.empty?(dir)
      raise ArgumentError, 'The given directory exists and is not empty'
    end

    document_configuration = DocumentConfiguration.new

    File.open(File.join(dir, 'document.json'), 'w') do |f|
      f.write(document_configuration.to_json)
    end
  end
end
