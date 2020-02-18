require 'json'

# The document configuration.
#
# This class exposes an interface to define a new configuration that's compliant
# with the schema document.schema.json.
#
# @field [Hash] current_configuration The internal hash for the configuration.
class DocumentConfiguration
  # The representation of an author.
  #
  # @field [String] name The author's name
  # @field [String] surname The author's surname
  # @field [String] email The author's email
  # @field [String] middlename The author's middle name
  class Author
    # Create a new Author
    #
    # @param [String] name The author's name
    # @param [String] surname The author's surname
    # @param [String] email The author's email
    # @param [String] middlename The author's middle name
    # @raise [ArgumentError] if name and/or surname are nil or empty.
    def initialize(name, surname, email = nil, middlename = nil)
      if name.nil? || name.strip.empty?
        raise ArgumentError, "Author's name can't be empty"
      end
      if surname.nil? || surname.strip.empty?
        raise ArgumentError, "Author's surname can't be empty"
      end

      @name = name.strip
      @surname = surname.strip
      @email = email.nil? ? nil : email.strip
      @middlename = middlename.nil? ? nil : middlename.strip
    end

    # Convert the author object to an hash object
    #
    # @return [Hash] The hash representation of the author
    def to_hash
      dict = { name: @name, surname: @surname }
      dict[:email] = @email unless @email.nil? || @email.empty?
      unless @middlename.nil? || @middlename.empty?
        dict[:middlename] = @middlename
      end
      dict
    end

    # Check if two authors are equals
    #
    # @param [Object] other The other object.
    # @return [Boolean] True if the author and object are equals.
    def ==(other)
      self.class == other.class && to_hash == other.to_hash
    end

    # Convert the author to JSON
    #
    # @param opts
    # @return [String] the JSON representation of the author.
    def to_json(*opts)
      dict = to_hash
      dict.to_json(*opts)
    end
  end

  # Create a new empty document configuration
  def initialize
    @current_configuration = {}
  end

  # Set the title of the document
  #
  # @param [String] title The new title
  # @raise [ArgumentError] if the title is nil or empty
  def title=(title)
    if title.nil? || title.strip.empty?
      raise ArgumentError, "The title can't be empty"
    end

    @current_configuration[:title] = title.strip
  end

  # Set the authors' list of the document
  #
  # @param [Array<DocumentConfiguration::Author>] authors The new authors
  # @raise [ArgumentError] if the authors' list contains duplicates
  def authors=(authors)
    if authors.detect { |e| authors.count(e) > 1 }
      raise ArgumentError, 'The authors list must not contain duplicates!'
    end

    @current_configuration[:authors] = authors
  end

  # Convert the configuration to an hash object
  #
  # @return [Hash] the hash representation of the configuration
  def to_hash
    @current_configuration
  end

  # Convert the configuration to JSON
  #
  # @param opts
  # @return [String] The JSON representation of the configuration
  def to_json(*opts)
    JSON.pretty_generate(@current_configuration, *opts)
  end
end