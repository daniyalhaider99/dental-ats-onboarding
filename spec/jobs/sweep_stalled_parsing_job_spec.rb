require "rails_helper"

RSpec.describe SweepStalledParsingJob do
  it "fails documents stuck in progress past the timeout and leaves the rest alone" do
    stalled = create(:candidate_document, :processing)
    stalled.update_column(:updated_at, 1.hour.ago)

    healthy = create(:candidate_document, :processing)
    completed = create(:candidate_document, :completed)

    described_class.perform_now

    expect(stalled.reload).to be_parsing_failed
    expect(healthy.reload).to be_parsing_processing
    expect(completed.reload).to be_parsing_completed
  end

  it "broadcasts the status change so a waiting candidate sees the manual form" do
    stalled = create(:candidate_document, :processing)
    stalled.update_column(:updated_at, 1.hour.ago)

    allow(Onboarding::StatusBroadcast).to receive(:call)
    described_class.perform_now
    expect(Onboarding::StatusBroadcast).to have_received(:call).with(stalled.candidate_profile)
  end
end
