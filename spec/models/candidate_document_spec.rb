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

  describe "stalled parsing" do
    it "is stalled when it has been processing past the timeout" do
      document = create(:candidate_document, :processing)
      document.update_column(:updated_at, (described_class::STALE_AFTER + 1.minute).ago)
      expect(document).to be_parsing_stalled
    end

    it "is not stalled while still within the timeout" do
      expect(create(:candidate_document, :processing)).not_to be_parsing_stalled
    end

    it "is never stalled once finished" do
      document = create(:candidate_document, :completed)
      document.update_column(:updated_at, 1.hour.ago)
      expect(document).not_to be_parsing_stalled
    end

    describe "#fail_as_stalled!" do
      it "transitions a stalled document to failed with a manual-entry message" do
        document = create(:candidate_document, :processing)
        document.update_column(:updated_at, 1.hour.ago)

        expect(document.fail_as_stalled!).to be_truthy
        expect(document.reload).to be_parsing_failed
        expect(document.parsing_error).to include("manually")
      end

      it "leaves a healthy in-progress document untouched" do
        document = create(:candidate_document, :processing)
        expect(document.fail_as_stalled!).to be(false)
        expect(document.reload).to be_parsing_processing
      end
    end
  end
end
