# frozen_string_literal: true

require 'net/http'
require 'uri'

module AsciiDocPublishingToolbox
  # A document
  class Document
    # @return [AsciiDocPublishingToolbox::Document::DocumentConfiguration] The document configuration.
    attr_reader :config
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

      lang_url = "https://raw.githubusercontent.com/asciidoctor/asciidoctor/master/data/locale/attributes-#{@config.lang}.adoc"
      <<~DOC
        = #{@config.title}
        #{author_string.join('; ')}
        #{version}
        :doctype: #{@config.type}
        :toc: left
        :sectnums:
        :partnums:
        :sectnumsdepth: 5
        :xrefstyle: short
        :copyright-year: #{@config.copyright[:fromYear]}#{"--#{@config.copyright[:toYear]}" if @config.copyright[:toYear]}
        :lang: #{@config.lang}
        #{Net::HTTP.get(URI.parse(lang_url))}

        #{colophon}

        #{@config.chapters.map { |ch| "include::src/#{ch['title'].downcase.gsub(' ', '-')}.adoc[#{'leveloffset=+1' unless ch['part']}]" }.join("\n\n")}

        #{revision_history}
      DOC
    end

    def revision_history
      return '// No version specified' if @config.version.nil? || @config.version.empty?
      return '// revhistory option is false' if @config.options.nil? || !@config.options

      <<~REV_HISTORY
        [appendix]
        == #{@config.options[:revhistoryLabel]}

        .#{@config.options[:revhistoryLabel]}
        [options="header", cols="^.^,^.^2,2*^.^3"]
        |===
        | {version-label} | Date | Description | Author
        #{@config.version.map { |ver| "| #{ver[:number]} | #{ver[:date] || 'N/A'} | #{ver[:note] || 'N/A'} | #{ver[:author] || 'N/A'}" }.join("\n")}
        |===
      REV_HISTORY
    end

    def version
      return '// No version specified' unless @config.current_version

      ver = "v#{@config.current_version[:number]}"
      ver += ", #{@config.current_version[:date]}" if @config.current_version[:date]
      ver += ": #{@config.current_version[:note]}" if @config.current_version[:note]
      ver += " [#{@config.current_version[:author]}]" if @config.current_version[:author]
      ver
    end

    def colophon
      <<~COLOPHON
        [colophon#colophon%nonfacing]
        == {doctitle}

        Copyright (c) {copyright-year}, #{@config.copyright[:holder] || '{author}'}.

        #{@config.copyright[:text] || ''}

        #{'_Created using ADPT, the AsciiDoc Publishing Toolbox_.' unless @config.copyright[:adptNotice] == false}
      COLOPHON
    end
  end
end
