require "rails_helper"

RSpec.describe CandidateProfiles::FieldProvenance do
  def provenance(metadata)
    described_class.new(build(:candidate_profile, extraction_metadata: metadata))
  end

  it "reports a field with cv source as extracted" do
    p = provenance("first_name" => { "source" => "cv" })
    expect(p.state(:first_name)).to eq(:extracted)
    expect(p).to be_extracted(:first_name)
  end

  it "reports a low-confidence field as needs_review" do
    p = provenance("phone" => { "source" => "cv", "needs_review" => true })
    expect(p.state(:phone)).to eq(:needs_review)
    expect(p).to be_needs_review(:phone)
  end

  it "reports an absent field as missing" do
    p = provenance({})
    expect(p.state(:city)).to eq(:missing)
    expect(p).to be_missing(:city)
  end

  it "treats a nil metadata safely as missing" do
    p = described_class.new(build(:candidate_profile, extraction_metadata: nil))
    expect(p.state(:email)).to eq(:missing)
  end
end
