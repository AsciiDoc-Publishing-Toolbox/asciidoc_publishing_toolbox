# frozen_string_literal: true

require 'minitest/autorun'
require 'asciidoc_publishing_toolbox'
require 'fileutils'
require 'faker'
require 'json'
require 'yaml'
require 'asciidoc_publishing_toolbox/document/document_configuration'

class AsciiDocPublishingToolboxTest < Minitest::Test
  # def test_hi
  #   assert_equal 'hello world', AsciiDocPublishingToolbox.hi
  # end
  #
  TARGET_DIR = 'TESTING_DIRECTORY/'

  def test_init
    3.times do

      authors = []
      (1..Faker::Number.between(from: 1, to: 4)).each do |_|
        first_name = Faker::Name.first_name
        surname = Faker::Name.last_name
        middlename = Faker::Boolean.boolean ? Faker::Name.middle_name : nil
        email = Faker::Internet.safe_email name: "#{first_name} #{middlename ? middlename + ' ' + surname : surname}"
        author = AsciiDocPublishingToolbox::Document::Author.new first_name, surname, email, middlename
        authors << author
      end

      expected = {
        title: Faker::Book.title,
        authors: authors.map(&:to_hash),
        chapters: [{ title: Faker::Book.title }],
        lang: Faker::Nation.language.downcase[0..1],
        copyright: { fromYear: Faker::Date.backward.year }
      }

      has_to_overwrite = Faker::Boolean.boolean(true_ratio: 0)


      if !has_to_overwrite && Dir.exist?(TARGET_DIR)
        assert_raises(ArgumentError) do
          AsciiDocPublishingToolbox::Utilities.check_target_directory TARGET_DIR, has_to_overwrite, true
        end
      else
        AsciiDocPublishingToolbox::Utilities.check_target_directory TARGET_DIR, has_to_overwrite, true
        AsciiDocPublishingToolbox.init dir: TARGET_DIR, overwrite: has_to_overwrite, title: expected[:title], authors: authors,
                                       first_chapter: expected[:chapters][0][:title],
                                       lang: expected[:lang], copyright: expected[:copyright]
        actual = YAML.load_file File.join(TARGET_DIR, AsciiDocPublishingToolbox::Document::DocumentConfiguration::FILE_NAME)
        assert_equal JSON.parse(JSON.dump(expected)), actual
      end
    end
  end

  def teardown
    FileUtils.rmtree TARGET_DIR
  end


end
