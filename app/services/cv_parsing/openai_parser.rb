module CvParsing
  class OpenAIParser
    SCHEMA_NAME = "cv_extraction".freeze

    def self.call(cv_text:, client: OpenAI::Client.new)
      new(cv_text: cv_text, client: client).call
    end

    def initialize(cv_text:, client:)
      @cv_text = cv_text
      @client = client
    end

    def call
      raw = request_extraction
      parsed = parse_json(raw)
      ValidateResult.call(parsed)

      ServiceResult.success(parsed)
    rescue InvalidResponseError => e
      ServiceResult.failure(e.message, value: :invalid_json)
    end

    private

    attr_reader :cv_text, :client

    def request_extraction(correction: nil)
      response = client.responses(payload(correction))
      extract_output_text(response)
    end

    def parse_json(raw)
      attempt_parse(raw)
    rescue InvalidResponseError => e
      corrected = request_extraction(correction: e.message)
      attempt_parse(corrected)
    end

    def attempt_parse(raw)
      JSON.parse(raw)
    rescue JSON::ParserError => e
      raise InvalidResponseError, "model did not return valid JSON: #{e.message}"
    end

    def payload(correction)
      input = [
        { role: "system", content: Prompt.system },
        { role: "user", content: Prompt.user(cv_text) }
      ]
      input << { role: "user", content: correction_message(correction) } if correction

      {
        model: Settings.openai_model,
        temperature: Settings.openai_temperature,
        input: input,
        text: {
          format: {
            type: "json_schema",
            name: SCHEMA_NAME,
            strict: true,
            schema: ValidateResult.schema
          }
        }
      }
    end

    def correction_message(error)
      "Your previous response was rejected: #{error}. Return only the structured " \
        "object exactly as required by the schema."
    end

    def extract_output_text(response)
      text = dig_output_text(response)
      raise InvalidResponseError, "model returned an empty response" if text.blank?

      text
    end

    def dig_output_text(response)
      return response["output_text"] if response["output_text"].present?

      Array(response["output"]).flat_map { |item| Array(item["content"]) }
                               .filter_map { |part| part["text"] }
                               .join
    end
  end
end
