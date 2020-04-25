# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'asciidoc_publishing_toolbox/document/strings'
require 'asciidoc_publishing_toolbox/utilities'

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

    def file_name(extension = nil)
      unless extension.nil? || extension.empty? 
        extension = extension.downcase
        return 'index.html' if extension == 'html' && /^github/.match(@config.options[:target])
        
        "#{Utilities.get_id @config.title}.#{extension}"
      else
        Utilities.get_id @config.title
      end
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

      has_to_print_author = @config.version.any? { |h| !h[:author].nil? && !h[:author].empty? }

      <<~REV_HISTORY
        [appendix]
        == #{Strings.strings(@config.lang)['revhistory-label']}

        .#{Strings.strings(@config.lang)['revhistory-label']}
        [options="header", cols="^.^,^.^2,#{'2*' if has_to_print_author}^.^3"]
        |===
        | {version-label} | Date | Description #{'| Author' if has_to_print_author}
        #{@config.version.map { |ver| "| #{ver[:number]} | #{ver[:date] || 'N/A'} | #{ver[:note].gsub(/"(.*?)"/, '"`\1`"').gsub(/'(.*?)'/, '\'`\1`\'') rescue 'N/A'} #{"| #{ver[:author] || 'N/A'}" if has_to_print_author }" }.join("\n")}
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

        #{"_#{Strings.strings(@config.lang)['created-with-adpt-notice']}_." unless @config.copyright[:adptNotice] == false}
      COLOPHON
    end
  end
end
