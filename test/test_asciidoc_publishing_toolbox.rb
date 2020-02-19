# frozen_string_literal: true

require 'minitest/autorun'
require 'asciidoc_publishing_toolbox'
require 'fileutils'
require 'json'

class AsciiDocPublishingToolboxTest < Minitest::Test
  # def test_hi
  #   assert_equal 'hello world', AsciiDocPublishingToolbox.hi
  # end
  #
  def test_init
    target_dir = 'TESTING_DIRECTORY/'

    expected = {
      title: 'A test document',
      authors: [
        {
          name: 'Andrea',
          surname: 'Esposito',
          email: 'email@provider.com',
        },
        {
          name: 'Second',
          surname: 'Author',
          middlename: 'Test'
        },
        {
          name: 'Third',
          surname: 'Author'
        },
        {
          name: 'Fourth',
          surname: 'Author',
          middlename: 'Test',
          email: 'test@test.com'
        }
      ]
    }

    authors = expected[:authors].map { |el| DocumentConfiguration::Author.new el[:name], el[:surname], el[:email], el[:middlename] }
    AsciiDocPublishingToolbox.init dir: target_dir, overwrite: true, title: expected[:title], authors: authors
    actual = JSON.parse File.read(File.join(target_dir, 'document.json')), symbolize_names: true

    FileUtils.rmtree target_dir

    assert_equal expected, actual
  end
end