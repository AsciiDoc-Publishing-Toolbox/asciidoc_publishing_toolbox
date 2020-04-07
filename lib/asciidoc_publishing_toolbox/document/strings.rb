# frozen_string_literal: true

module AsciiDocPublishingToolbox
  class Document
    class Strings
      @@strings = {
        it: {
          'revhistory-label': 'Storico delle revisioni',
          'created-with-adpt-notice': 'Creato utilizzando ADPT, la Toolbox per la Pubblicazione in AsciiDoc',
        },
        en: {
          'revhistory-label': 'Revision History',
          'created-with-adpt-notice': 'Created using ADPT, the AsciiDoc Publishing Toolbox',
        },
      }

      def self.strings(lang)
        lang = (lang.is_a? String)? lang.to_sym : lang
        return @@strins[:en] unless @@strings.has_key? lang

        @@strings[lang]
      end

      def self.to_adoc(strings)
        out = ''
        strings.each { |k, v| out += ":#{k.to_s.strip}: #{v.strip}\n" }
        out
      end
    end
  end
end
