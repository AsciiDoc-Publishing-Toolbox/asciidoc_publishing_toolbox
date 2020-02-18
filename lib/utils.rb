# A utility class
class Utils
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

  def self.get_authors_input
    input = []
    first_name = gets_not_empty 'Insert the first author name'
    surname = gets_not_empty 'Insert the first author surname'
    middlename = get_input "Insert the first author middle name [default: '']: "
    middlename.chomp!
    email = get_input "Insert the first author email [default: '']: "
    email.chomp!

    author = {name: first_name, surname: surname, middlename: middlename, email: email}
    input.push author

    until first_name.empty?
      first_name = get_input 'Insert the first author name (leave empty to stop)'
      first_name.chomp!

      next if first_name.empty?

      surname = gets_not_empty 'Insert the first author surname'
      middlename = get_input "Insert the first author middle name [default: '']: "
      middlename.chomp!
      email = get_input "Insert the first author email [default: '']: "
      email.chomp!

      author = {name: first_name, surname: surname, middlename: middlename, email: email}
      input.push author
    end

    input
  end
end
