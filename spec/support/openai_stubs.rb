module OpenAIStubs
  def stub_openai_extraction(payload)
    body = { "output" => [ { "type" => "message", "content" => [ { "type" => "output_text", "text" => payload.to_json } ] } ] }

    stub_request(:post, OpenAI::Client::ENDPOINT)
      .to_return(status: 200, body: body.to_json, headers: { "Content-Type" => "application/json" })
  end

  def stub_openai_error(status: 500, body: "upstream error")
    stub_request(:post, OpenAI::Client::ENDPOINT).to_return(status: status, body: body)
  end
end

RSpec.configure do |config|
  config.include OpenAIStubs
  config.before { ENV["OPENAI_API_KEY"] ||= "test-key" }
end
