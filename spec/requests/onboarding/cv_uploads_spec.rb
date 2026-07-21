require "rails_helper"

RSpec.describe "Onboarding CV uploads" do
  before do
    seed_reference_data
    stub_openai_extraction(
      "personal_details" => { "first_name" => "Anna", "last_name" => "de Vries", "email" => "anna@example.nl", "phone" => "+31612345678", "city" => "Amsterdam", "country" => "NL" },
      "job_preferences" => { "current_job_title" => nil, "suggested_job_function" => nil },
      "employment" => { "big_status" => nil, "big_number" => nil, "years_of_experience" => nil },
      "educations" => [], "work_experiences" => [], "languages" => [],
      "skills" => [], "availability" => { "available_from" => nil, "notice_period" => nil },
      "summary" => nil, "low_confidence_fields" => []
    )
  end

  def upload_params(file: fixture_file_upload("sample.pdf", "application/pdf"), consent: "1")
    { onboarding_upload_form: { file: file, consent: consent } }
  end

  it "renders the upload screen" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Upload your CV")
  end

  it "accepts a valid CV and creates a pending document" do
    expect do
      post onboarding_cv_upload_path, params: upload_params
    end.to change(CandidateDocument, :count).by(1)

    expect(response).to redirect_to(onboarding_profile_path)
    expect(CandidateDocument.last).to be_parsing_pending.or be_parsing_completed
  end

  it "enqueues the parsing job" do
    expect do
      post onboarding_cv_upload_path, params: upload_params
    end.to have_enqueued_job(ParseCandidateCvJob)
  end

  it "rejects a file disguised with the wrong content" do
    disguised = Tempfile.new([ "fake", ".pdf" ]).tap { |f| f.write("not a pdf"); f.rewind }
    file = Rack::Test::UploadedFile.new(disguised.path, "application/pdf")

    post onboarding_cv_upload_path, params: upload_params(file: file)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("PDF, DOC or DOCX")
  end

  it "requires consent" do
    post onboarding_cv_upload_path, params: upload_params(consent: "0")
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
