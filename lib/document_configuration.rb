require 'json'

class DocumentConfiguration
  class Author
    def initialize(name, surname, email = nil, middlename = nil)
      @name = name
      @surname = surname
      @email = email
      @middlename = middlename
    end

    def to_hash
      dict = {name: @name, surname: @surname}
      dict[:email] = @email unless @email.nil? || @email.empty?
      unless @middlename.nil? || @middlename.empty?
        dict[:middlename] = @middlename
      end
      dict
    end


    def ==(other)
      self.class == other.class && to_hash == other.to_hash
    end

    def to_json(*opts)
      dict = to_hash
      dict.to_json(*opts)
    end
  end

  def initialize()
    @current_configuration = {}
  end

  def title=(title)
    @current_configuration[:title] = title
  end

  def authors=(authors)
    if authors.detect { |e| authors.count(e) > 1 }
      raise ArgumentError, 'The authors list must not contain duplicates!'
    end

    @current_configuration[:authors] = authors
  end

  def to_hash
    @current_configuration
  end

  def to_json(*opts)
    JSON.pretty_generate(@current_configuration, *opts)
  end
end