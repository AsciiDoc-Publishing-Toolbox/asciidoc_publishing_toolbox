# frozen_string_literal: true

require 'yaml'
require 'json_schemer'
require 'json'
require 'date'
require 'net/http'
require 'asciidoc_publishing_toolbox/document/author'
require 'asciidoc_publishing_toolbox/errors'

module AsciiDocPublishingToolbox
  class Document
    # The document configuration.
    #
    # This class exposes an interface to define a new configuration that's compliant
    # with the schema document.schema.json.
    class DocumentConfiguration
      attr_reader :title, :authors, :type, :chapters, :lang, :copyright, :version
      FILE_NAME = 'document.yml'
      SCHEMA = 'https://asciidoc-publishing-toolbox.github.io/document-schema/schemas/document.schema.json'

      module DocumentType
        BOOK = 'book'
        ARTICLE = 'article'

        def self.value_for_name(name)
          const_get name.upcase, false
        end
      end

      # Create a new empty document configuration
      def initialize(opts = { title: nil, authors: nil })
        @title = validate_title opts[:title] unless opts[:title].nil?
        @authors = validate_author_list opts[:authors] unless opts[:authors].nil?
        @type = opts[:type] || DocumentType::BOOK
        @chapters = validate_chapter_list opts[:chapters]
        @lang = (opts[:lang] || 'en').strip.downcase
        @copyright = (opts[:copyright] || { fromYear: Date.today.year })
        @version = (opts[:version] || nil)
      end

      # Load an existing configuration
      # @param [String,Pathname,Hash] configuration The existing configuration. If
      #   it's a string, it's treated as a JSON string; if it's a Pathname it's
      #   treated as the path to the directory containing the configuration; if it's an
      #   Hash it's treated as the configuration itself.
      #
      # @raise [ArgumentError] if configuration is not of an accepted type
      # @return [DocumentConfiguration] The loaded configuration
      def self.load(configuration)
        case configuration
        when String
          configuration = YAML.safe_load configuration
        when Pathname
          configuration = YAML.load_file(configuration + FILE_NAME)
        else
          raise ArgumentError, "Unsupported type (#{configuration.class.name}) for 'configuration'" unless configuration.is_a? Hash
        end

        schemer = JSONSchemer.schema(Net::HTTP.get(URI.parse(SCHEMA)), ref_resolver: 'net/http', insert_property_defaults: true, format: false)
        errors = schemer.validate(configuration).to_a
        raise InvalidConfigurationError, errors.to_s unless errors.empty?

        authors = []
        configuration['authors'].each do |author|
          authors << Author.new(author['name'], author['surname'], author['email'], author['middlename'])
        end
        
        version = configuration['versions'] rescue nil
        version.map! { |el| el.transform_keys(&:to_sym) } if version

        type = DocumentType.value_for_name configuration['type'] rescue DocumentType::BOOK
        DocumentConfiguration.new title: configuration['title'], authors: authors,
                                  type: type, chapters: configuration['chapters'],
                                  lang: configuration['lang'],
                                  copyright: configuration['copyright'].transform_keys(&:to_sym),
                                  version: version
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

      def self.document?(dir)
        Dir.exist?(dir) && !Dir.empty?(dir) && File.exist?(File.join(dir, DocumentConfiguration::FILE_NAME))
      end

      def add_chapter(title, is_part = false)
        @chapters = validate_chapter_list @chapters, { title: title, part: is_part }
      end

      def rename_chapter(chapter, new_title)
        @chapters[chapter][:title] = new_title
        raise ArgumentError unless validate_chapter_list @chapters
      end

      # Convert the configuration to an hash object
      #
      # @return [Hash] the hash representation of the configuration
      def to_hash
        hash = {
          title: @title,
          authors: @authors.map(&:to_hash),
          chapters: @chapters,
          lang: @lang,
          copyright: @copyright
        }
        hash[:version] = @version if @version
        hash
      end

      def current_version
        unless @version.nil? || @version.empty? then version[0] else nil end
      end

      # Convert the configuration to JSON
      #
      # @return [String] The JSON representation of the configuration
      def to_yaml
        JSON.parse(JSON.dump(to_hash)).to_yaml
      end

      # Write the configuration to a JSON file
      #
      # @param [String] directory The directory where the file will be stored
      def write_file(directory)
        File.open(File.join(directory, FILE_NAME), 'w') do |f|
          f.write to_yaml
        end
      end

      private

      def validate_chapter_list(chapters, new_chap = nil)
        if new_chap
          chapters.each do |ch|
            ch.transform_keys!(&:to_sym)
            if ch[:title].downcase.gsub(' ', '-') == new_chap[:title].downcase.gsub(' ', '-')
              raise ArgumentError, 'The chapter "ID" must be unique (title in lower case, with spaces replaced by hypens "-")'
            end
          end
          chapters << new_chap
        else
          return chapters unless chapters.detect { |e| chapters.count(e) > 1 }
        end
      end

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
end
