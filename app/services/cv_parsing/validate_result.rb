module CvParsing
  module ValidateResult
    SCHEMA_PATH = Rails.root.join("config/schemas/cv_extraction.json")

    module_function

    def schema
      @schema ||= JSON.parse(SCHEMA_PATH.read)
    end

    def call(parsed)
      errors = JSON::Validator.fully_validate(schema, parsed)
      return true if errors.empty?

      raise InvalidResponseError, "response did not match the schema: #{errors.first(3).join('; ')}"
    end
  end
end
