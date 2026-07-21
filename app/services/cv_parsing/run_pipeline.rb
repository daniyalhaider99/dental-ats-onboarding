module CvParsing
  class RunPipeline
    def self.call(document)
      new(document).call
    end

    def initialize(document)
      @document = document
    end

    def call
      document.update!(parsing_status: :processing)

      extraction = ExtractText.call(document)
      return fail_with(extraction.error) if extraction.failure?

      parsing = OpenAIParser.call(cv_text: extraction.value)
      return fail_with(parsing.error) if parsing.failure?

      persist(parsing.value)
      complete_with(parsing.value)
    rescue ApiError
      document.update!(parsing_status: :processing)
      raise
    rescue StandardError => e
      fail_with("#{e.class}: #{e.message}")
      raise
    end

    private

    attr_reader :document

    def persist(parsed)
      mapped = MapResult.call(parsed)
      SaveResult.call(profile: document.candidate_profile, mapped: mapped)
    end

    def complete_with(parsed)
      document.update!(
        raw_parser_output: parsed,
        parsing_status: :completed,
        parsed_at: Time.current,
        parsing_error: nil
      )
      ServiceResult.success(document)
    end

    def fail_with(message)
      document.update!(
        parsing_status: :failed,
        parsed_at: Time.current,
        parsing_error: message
      )
      ServiceResult.failure(message)
    end
  end
end
