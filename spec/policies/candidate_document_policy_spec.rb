require "rails_helper"

RSpec.describe CandidateDocumentPolicy do
  let(:document) { build(:candidate_document) }

  it "allows the admin actor to download" do
    expect(described_class.new(actor: :admin, document: document).download?).to be(true)
  end

  it "denies a nil actor" do
    expect(described_class.new(actor: nil, document: document).download?).to be(false)
  end

  it "denies any non-admin actor" do
    expect(described_class.new(actor: :candidate, document: document).download?).to be(false)
  end
end
