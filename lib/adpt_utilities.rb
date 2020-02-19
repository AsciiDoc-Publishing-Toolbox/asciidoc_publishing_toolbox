# frozen_string_literal: true

# A utility class
class ADPTUtilities
  # Get an input from the user
  #
  # @param [String] prompt A message to prompt to the user
  # @return [String] The value given by the user (chomped).
  def self.get_input(prompt = '')
    print prompt + ' '
    input = gets
    input.chomp
  end

  # Get a string in input.
  #
  # @param [String] prompt A prompt for the user
  # @param [String] error_message An error message to be printed in case of an
  #   empty string
  # @return [String] The given string (chomped).
  def self.gets_not_empty(prompt = '', error_message = 'No value inserted.')
    input = nil
    while input.nil? || input.empty?
      print error_message + ' ' unless input.nil?
      input = get_input prompt
    end
    input
  end

  # Get a list of author in input from the user
  #
  # @return [Array<DocumentConfiguration::Author>] An array containing the
  #   given authors
  def self.get_authors_input
    input = []
    loop do
      begin
        first_name = if input.empty?
                       gets_not_empty("Insert the #{input.length + 1}° author name")
                     else
                       get_input("Insert the #{input.length + 1}° author name (leave empty to stop)")
                     end

        author = DocumentConfiguration::Author.from_string first_name
      rescue ArgumentError => e
        puts e.message
        retry
      end
      break if first_name.empty?

      unless author
        surname = gets_not_empty "Insert the #{input.length + 1}° author surname"
        middle_name = get_input "Insert the #{input.length + 1}° author middle name [default: '']: "
        email = get_input "Insert the #{input.length + 1}° author email [default: '']: "

        author = DocumentConfiguration::Author.new first_name, surname, email, middle_name
      end
      input.push author
    end

    input
  end
end
