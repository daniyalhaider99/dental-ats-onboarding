require "rails_helper"

RSpec.describe ParseCandidateCvJob do
  include ActiveJob::TestHelper

  before { seed_reference_data }

  let(:profile) { create(:candidate_profile) }
  let(:document) do
    document = profile.candidate_documents.build(
      document_type: :cv, original_filename: "sample.pdf", content_type: "application/pdf", file_size: 1, parsing_status: :pending
    )
    document.file.attach(io: File.open(cv_fixture_path("sample.pdf")), filename: "sample.pdf", content_type: "application/pdf")
    document.save!
    document
  end

  let(:payload) do
    {
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "NL" },
      "job_preferences" => { "current_job_title" => "Tandarts", "suggested_job_function" => "general_dentist" },
      "employment" => { "big_status" => "registered", "big_number" => "123", "years_of_experience" => 7 },
      "educations" => [], "work_experiences" => [], "languages" => [],
      "skills" => [], "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => []
    }
  end

  it "parses the CV and prefills the profile" do
    stub_openai_extraction(payload)

    described_class.perform_now(document)

    expect(document.reload).to be_parsing_completed
    expect(profile.reload.first_name).to eq("Anna")
  end

  it "marks the document failed when extraction yields nothing" do
    document.file.attach(io: StringIO.new("%PDF-1.4\n%%EOF\n"), filename: "empty.pdf", content_type: "application/pdf")
    document.save!

    described_class.perform_now(document)

    expect(document.reload).to be_parsing_failed
    expect(document.parsing_error).to be_present
  end

  it "re-enqueues itself on a transient API error instead of failing immediately" do
    stub_openai_error(status: 503)

    expect { described_class.perform_now(document) }.to have_enqueued_job(described_class)
    expect(document.reload).not_to be_parsing_failed
  end

  it "does nothing once the document is already completed" do
    document.update!(parsing_status: :completed, parsed_at: Time.current)

    expect(CvParsing::RunPipeline).not_to receive(:call)
    described_class.perform_now(document)
  end
end
