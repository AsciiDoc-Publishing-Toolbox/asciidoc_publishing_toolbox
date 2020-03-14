# frozen_string_literal: true

require 'minitest/autorun'
require 'asciidoc_publishing_toolbox'
require 'fileutils'
require 'json'
require 'asciidoc_publishing_toolbox/document/document_configuration'

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
      ],
      chapters: [{ title: 'First Chapter Title' }],
      lang: 'en',
      copyright: { fromYear: 2020 }
    }

    authors = expected[:authors].map { |el| AsciiDocPublishingToolbox::Document::Author.new el[:name], el[:surname], el[:email], el[:middlename] }
    AsciiDocPublishingToolbox::Utilities.check_target_directory target_dir, true, true
    AsciiDocPublishingToolbox.init dir: target_dir, overwrite: true, title: expected[:title], authors: authors,
                                   first_chapter: expected[:chapters][0][:title],
                                   lang: expected[:lang], copyright: expected[:copyright]
    actual = YAML.load_file File.join(target_dir, AsciiDocPublishingToolbox::Document::DocumentConfiguration::FILE_NAME)

    FileUtils.rmtree target_dir

    assert_equal expected, actual
  end
end