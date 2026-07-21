require "rails_helper"

RSpec.describe CandidateDocument do
  it { is_expected.to belong_to(:candidate_profile) }
  it { is_expected.to validate_presence_of(:original_filename) }

  it "rejects an unsupported content type" do
    document = build(:candidate_document, content_type: "text/plain")
    expect(document).to be_invalid
    expect(document.errors[:content_type]).to be_present
  end

  describe "#format" do
    it "derives the extraction format from the content type" do
      expect(build(:candidate_document, content_type: "application/pdf").format).to eq(:pdf)
    end
  end

  describe "status helpers" do
    it "reports in-progress for pending and processing" do
      expect(build(:candidate_document, parsing_status: :pending)).to be_parsing_in_progress
      expect(build(:candidate_document, parsing_status: :processing)).to be_parsing_in_progress
    end

    it "reports finished for completed and failed" do
      expect(build(:candidate_document, parsing_status: :completed)).to be_parsing_finished
      expect(build(:candidate_document, parsing_status: :failed)).to be_parsing_finished
    end
  end
end
