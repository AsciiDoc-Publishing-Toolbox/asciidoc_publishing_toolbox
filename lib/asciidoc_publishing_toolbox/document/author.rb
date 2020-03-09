# frozen_string_literal: true

module AsciiDocPublishingToolbox
  module Document
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
        dict = {name: @first_name, surname: @surname}
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
  end
end
