module OpenAI
  class Client
    ENDPOINT = "https://api.openai.com/v1/responses".freeze

    def initialize(api_key: self.class.api_key, timeout: CvParsing::Settings.request_timeout)
      @api_key = api_key
      @timeout = timeout
    end

    def self.api_key
      Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"]
    end

    def responses(payload)
      raise CvParsing::ApiError, "OpenAI API key is not configured" if api_key.blank?

      response = post(payload)

      unless response.is_a?(Net::HTTPSuccess)
        raise CvParsing::ApiError, "OpenAI responded #{response.code}: #{response.body.to_s.first(500)}"
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise CvParsing::ApiError, "OpenAI returned a non-JSON body: #{e.message}"
    end

    private

    attr_reader :api_key, :timeout

    def post(payload)
      uri = URI(ENDPOINT)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = timeout
      http.read_timeout = timeout

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{api_key}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json

      http.request(request)
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise CvParsing::ApiError, "OpenAI request timed out after #{timeout}s: #{e.message}"
    rescue SocketError, SystemCallError => e
      raise CvParsing::ApiError, "OpenAI request failed: #{e.message}"
    end
  end
end
