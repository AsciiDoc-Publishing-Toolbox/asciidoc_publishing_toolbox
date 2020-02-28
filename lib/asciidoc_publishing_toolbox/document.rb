# frozen_string_literal: true

require 'faker'

# A document
class Document
  # Create a new document
  #
  # @param [DocumentConfiguration] config The document configuration
  def initialize(config)
    @config = config
  end

  def file_name
    @config.title.downcase.gsub(' ', '-')
  end

  # Get the document as string
  # @return [String] the document
  def to_s
    author_string = []
    @config.authors.each do |author|
      author_string << author.to_s
    end

    <<~DOC
      = #{@config.title}
      #{author_string.join('; ')}
      :doctype: book
      :toc:
    DOC
  end
end