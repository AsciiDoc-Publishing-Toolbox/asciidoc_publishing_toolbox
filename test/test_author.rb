# frozen_string_literal: true

require 'minitest/autorun'
require 'asciidoc_publishing_toolbox/document_configuration'

class AuthorTest < MiniTest::Test
  def test_from_string
    first_name = 'Name'
    surname = 'Surname'
    email = 'mail@mail.com'
    middle_name = 'Middlename'

    # Full string
    str = "#{first_name};#{middle_name};#{surname};#{email}"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname, email, middle_name)
    str = "#{first_name};;#{surname};#{email}"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname, email)
    str = "#{first_name};#{middle_name};#{surname};"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname, nil, middle_name)
    str = "#{first_name};;#{surname};"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname)

    # No middle name
    str = "#{first_name};#{surname};#{email}"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname, email)
    str = "#{first_name};#{surname};"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname)

    # No middle name, no email
    str = "#{first_name};#{surname}"
    assert_equal DocumentConfiguration::Author.from_string(str), DocumentConfiguration::Author.new(first_name, surname)

    # Invalid strings
    str = "#{first_name}"
    assert_nil DocumentConfiguration::Author.from_string(str)
    str = ''
    assert_nil DocumentConfiguration::Author.from_string(str)
    str = nil
    assert_nil DocumentConfiguration::Author.from_string(str)
    str = ' '
    assert_nil DocumentConfiguration::Author.from_string(str)
    str = "#{first_name},#{surname}"
    assert_nil DocumentConfiguration::Author.from_string(str)

    # Errors
    str = ";#{middle_name};#{surname};#{email}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = "#{first_name};#{middle_name};;#{email}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = ";#{middle_name};;#{email}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = ";#{surname};#{email}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = "#{first_name};;#{email}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = ";;#{email}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = "#{first_name};"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = ";#{surname}"
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
    str = ';'
    assert_raises(ArgumentError) { DocumentConfiguration::Author.from_string(str) }
  end
end