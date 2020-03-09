module AsciiDocPublishingToolbox
  # The base class for all ADPT's errors.
  class ADPTError < StandardError
    def self.status_code(code)
      define_method(:status_code) { code }
      if (match = ADPTError.all_errors.find { |_k, v| v == code })
        error, = match
        raise ArgumentError,
              "Trying to register #{self} for status code #{code} but #{error} is already registered"
      end
      ADPTError.all_errors[self] = code
    end

    def self.all_errors
      @all_errors ||= {}
    end
  end

  # An error that should be raised if a configuration is invalid.
  class InvalidConfigurationError < ADPTError; status_code(3); end
end
