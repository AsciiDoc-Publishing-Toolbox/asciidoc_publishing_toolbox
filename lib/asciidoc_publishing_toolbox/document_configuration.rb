# frozen_string_literal: true

require 'json'
require 'json_schemer'

module AsciiDocPublishingToolbox
  # The document configuration.
  #
  # This class exposes an interface to define a new configuration that's compliant
  # with the schema document.schema.json.
  class DocumentConfiguration
    attr_reader :title, :authors, :type, :chapters
    FILE_NAME = 'document.json'

    module DocumentType
      BOOK = 'book'
      ARTICLE = 'article'

      def self.value_for_name(name)
        const_get name.upcase, false
      end
    end

    # The representation of an author.
    class Author
      attr_reader :first_name, :surname, :email, :middle_name
      # Create a new Author
      #
      # @param [String] first_name The author's name
      # @param [String] surname The author's surname
      # @param [String] email The author's email
      # @param [String] middle_name The author's middle name
      # @raise [ArgumentError] if first name and/or surname are nil or empty.
      def initialize(first_name, surname, email = nil, middle_name = nil)
        @first_name = validate_first_name first_name
        @surname = validate_surname surname
        @email = email.nil? ? nil : email.strip
        @middle_name = middle_name.nil? ? nil : middle_name.strip
      end

      # Get an author from a string.
      #
      # @param [String] str The input string
      # @return [Hash, nil] nil if str is not an author, the author hash otherwise.
      # @raise [ArgumentError] see {#initialize}
      def self.from_string(str)
        return nil if str.nil? || str.strip.empty?

        if (match = str.match(/^(.*?);(.*?);(.*?);(.*?)$/i))
          first_name, middle_name, surname, email = match.captures
          Author.new first_name, surname, email, middle_name
        elsif (match = str.match(/^(.*?);(.*?);(.*?)$/i))
          first_name, surname, email = match.captures
          Author.new first_name, surname, email
        elsif (match = str.match(/^(.*?);(.*?)$/i))
          first_name, surname = match.captures
          Author.new first_name, surname
        end
      end

      # Convert the author object to an hash object
      #
      # @return [Hash] The hash representation of the author
      def to_hash
        dict = { name: @first_name, surname: @surname }
        dict[:email] = @email unless @email.nil? || @email.empty?
        unless @middle_name.nil? || @middle_name.empty?
          dict[:middlename] = @middle_name
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

      # Convert to string
      # @return [String] The author string (AsciiDoc-like)
      def to_s
        author_string = ''
        author_string += @first_name
        author_string += " #{@middle_name}" unless @middle_name.nil? || @middle_name.empty?
        author_string += " #{@surname}"
        author_string += " <#{@email}>" unless @email.nil? || @email.empty?
        author_string
      end

      # Convert the author to JSON
      #
      # @param opts
      # @return [String] the JSON representation of the author.
      def to_json(*opts)
        to_hash.to_json(*opts)
      end

      private

      def validate_first_name(first_name)
        return first_name.strip unless first_name.nil? || first_name.strip.empty?

        raise ArgumentError, "Author's name can't be empty"
      end

      def validate_surname(surname)
        return surname.strip unless surname.nil? || surname.strip.empty?

        raise ArgumentError, "Author's surname can't be empty"
      end
    end

    # An error that should be raised if a configuration is invalid.
    class InvalidConfigurationError < StandardError
      # Initialize the error
      #
      # @param msg The message.
      def initialize(msg = "The configuration file is not valid.")
        super
      end
    end
    # Create a new empty document configuration
    def initialize(opts = { title: nil, authors: nil })
      @title = validate_title opts[:title] unless opts[:title].nil?
      @authors = validate_author_list opts[:authors] unless opts[:authors].nil?
      @type = opts[:type] || DocumentType::BOOK
      @chapters = opts[:chapters]
    end

    # Load an existing configuration
    # @param [String,Pathname,Hash] configuration The existing configuration. If
    #   it's a string, it's treated as a JSON string; if it's a Pathname it's
    #   treated as the path to the file containing the configuration; if it's an
    #   Hash it's treated as the configuration itself.
    #
    # @raise [ArgumentError] if configuration is not of an accepted type
    # @return [DocumentConfiguration] The loaded configuration
    def self.load(configuration)
      case configuration
      when String
        configuration = JSON.parse configuration
      when Pathname
        configuration = File.read configuration + FILE_NAME
        configuration = JSON.parse configuration
      else
        raise ArgumentError, "Unsupported type (#{configuration.class.name}) for 'configuration'" unless configuration.is_a? Hash
      end
      schemer = JSONSchemer.schema(Pathname.new(File.join(__dir__, '../document.schema.json')))
      errors = schemer.validate(configuration).to_a
      raise InvalidConfigurationError, errors.to_s unless errors.empty?

      authors = []
      configuration['authors'].each do |author|
        authors << Author.new(author['name'], author['surname'], author['email'], author['middlename'])
      end
      type = DocumentType.value_for_name configuration['type'] rescue DocumentType::BOOK
      DocumentConfiguration.new title: configuration['title'], authors: authors, type: type, chapters: configuration['chapters']
    end

    # Check if the document is valid
    #
    # @return [Boolean] true if the object represents a valid object.
    def check_if_valid
      !@title.nil? && !@title.empty? && !@authors.nil? && !@authors.empty?
    end

    # Set the title of the document
    #
    # @param [String] title The new title
    # @raise [ArgumentError] if the title is nil or empty
    def title=(title)
      @title = validate_title title
    end

    # Set the authors' list of the document
    #
    # @param [Array<DocumentConfiguration::Author>] authors The new authors
    # @raise [ArgumentError] if the authors' list contains duplicates
    def authors=(authors)
      @authors = validate_author_list authors
    end

    def type=(type)
      @type = type
    end

    # Convert the configuration to an hash object
    #
    # @return [Hash] the hash representation of the configuration
    def to_hash
      {
        title: @title,
        authors: @authors,
        chapters: @chapters.map { |chap| { title: chap } }
      }
    end

    # Convert the configuration to JSON
    #
    # @param opts
    # @return [String] The JSON representation of the configuration
    def to_json(*opts)
      JSON.pretty_generate(to_hash, *opts)
    end

    # Write the configuration to a JSON file
    #
    # @param [String] directory The directory where the file will be stored
    def write_file(directory)
      File.open(File.join(directory, FILE_NAME), 'w') do |f|
        f.write to_json
      end
    end

    private

    def validate_author_list(authors)
      return authors unless authors.detect { |e| authors.count(e) > 1 }

      raise ArgumentError, 'The authors list must not contain duplicates!'
    end

    def validate_title(title)
      return title.strip unless title.nil? || title.strip.empty?

      raise ArgumentError, "The title can't be empty"
    end
  end
end