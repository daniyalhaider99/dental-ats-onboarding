require "rails_helper"

RSpec.describe CvParsing::OpenAIParser do
  def response_body(json)
    { "output" => [ { "type" => "message", "content" => [ { "type" => "output_text", "text" => json } ] } ] }
  end

  let(:valid_payload) do
    {
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "NL" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "123", "years_of_experience" => 7 },
      "educations" => [], "work_experiences" => [], "languages" => [],
      "skills" => [], "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => []
    }
  end

  let(:client) { instance_double(OpenAI::Client) }

  it "returns the parsed payload and requests a strict json schema at temperature 0" do
    captured = nil
    allow(client).to receive(:responses) do |payload|
      captured = payload
      response_body(valid_payload.to_json)
    end

    result = described_class.call(cv_text: "cv", client: client)

    expect(result).to be_success
    expect(result.value.dig("personal_details", "first_name")).to eq("Anna")
    expect(captured.dig(:text, :format, :strict)).to be(true)
    expect(captured[:temperature]).to eq(0)
  end

  it "re-asks once when the first response is not valid JSON" do
    responses = [ response_body("{ not json"), response_body(valid_payload.to_json) ]
    allow(client).to receive(:responses).and_return(*responses)

    result = described_class.call(cv_text: "cv", client: client)
    expect(result).to be_success
    expect(client).to have_received(:responses).twice
  end

  it "fails terminally when the JSON never validates" do
    allow(client).to receive(:responses).and_return(response_body("nope"), response_body("still nope"))
    result = described_class.call(cv_text: "cv", client: client)
    expect(result).to be_failure
    expect(result.value).to eq(:invalid_json)
  end

  it "lets an API error propagate so the job can retry" do
    allow(client).to receive(:responses).and_raise(CvParsing::ApiError, "503")
    expect { described_class.call(cv_text: "cv", client: client) }.to raise_error(CvParsing::ApiError)
  end
end
