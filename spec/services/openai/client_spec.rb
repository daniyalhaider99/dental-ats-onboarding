require "rails_helper"

RSpec.describe OpenAI::Client do
  subject(:client) { described_class.new(api_key: "test-key", timeout: 5) }

  let(:payload) { { model: "gpt", input: [] } }

  it "returns the parsed JSON body on success" do
    stub_request(:post, described_class::ENDPOINT)
      .with(headers: { "Authorization" => "Bearer test-key" })
      .to_return(status: 200, body: { "output" => [] }.to_json, headers: { "Content-Type" => "application/json" })

    expect(client.responses(payload)).to eq("output" => [])
  end

  it "raises ApiError without a key" do
    expect { described_class.new(api_key: nil).responses(payload) }
      .to raise_error(CvParsing::ApiError, /not configured/)
  end

  it "raises ApiError on a non-success response" do
    stub_request(:post, described_class::ENDPOINT).to_return(status: 500, body: "boom")
    expect { client.responses(payload) }.to raise_error(CvParsing::ApiError, /500/)
  end

  it "raises ApiError on a timeout" do
    stub_request(:post, described_class::ENDPOINT).to_timeout
    expect { client.responses(payload) }.to raise_error(CvParsing::ApiError, /timed out|failed/)
  end

  it "raises ApiError when the body is not JSON" do
    stub_request(:post, described_class::ENDPOINT).to_return(status: 200, body: "not json")
    expect { client.responses(payload) }.to raise_error(CvParsing::ApiError, /non-JSON/)
  end
end
