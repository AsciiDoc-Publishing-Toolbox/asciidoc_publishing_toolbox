# frozen_string_literal: true

require 'minitest/autorun'
require 'asciidoc_publishing_toolbox/document/strings'

class StringsTest < MiniTest::Test
  def test_to_adoc
    to_test = {
        'a' => 'value',
        'b' => 'value',
    }
    expected = "a: value\nb: value\n"

    result = AsciiDocPublishingToolbox::Document::Strings.to_adoc to_test
    assert_equal result, expected
  end
end
