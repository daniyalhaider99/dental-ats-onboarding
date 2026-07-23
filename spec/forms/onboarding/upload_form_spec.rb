require "rails_helper"

RSpec.describe Onboarding::UploadForm do
  def uploaded(path, declared_type:, filename: File.basename(path))
    Rack::Test::UploadedFile.new(path, declared_type, original_filename: filename)
  end

  let(:pdf) { uploaded(Rails.root.join("spec/fixtures/files/sample.pdf"), declared_type: "application/pdf") }

  it "is valid with a real PDF and consent" do
    expect(described_class.new(file: pdf, consent: "1")).to be_valid
  end

  it "detects the content type from the file's bytes" do
    form = described_class.new(file: pdf, consent: "1")
    expect(form.content_type).to eq("application/pdf")
  end

  it "requires a file" do
    form = described_class.new(consent: "1")
    expect(form).to be_invalid
    expect(form.errors[:file]).to be_present
  end

  it "requires consent" do
    form = described_class.new(file: pdf, consent: "0")
    expect(form).to be_invalid
    expect(form.errors[:consent]).to be_present
  end

  it "rejects a non-CV file even when it is renamed and its type is spoofed" do
    fake = Tempfile.new([ "cv", ".pdf" ])
    fake.write("just some text, definitely not a pdf")
    fake.rewind
    form = described_class.new(file: uploaded(fake.path, declared_type: "application/pdf", filename: "cv.pdf"), consent: "1")

    expect(form).to be_invalid
    expect(form.errors[:file].join).to include("PDF, DOC or DOCX")
  end

  it "rejects a file larger than the configured limit" do
    big = Tempfile.new([ "big", ".pdf" ])
    big.write("%PDF-1.4\n")
    big.write("0" * (CvParsing::Settings.max_file_size + 1))
    big.rewind
    form = described_class.new(file: uploaded(big.path, declared_type: "application/pdf"), consent: "1")

    expect(form).to be_invalid
    expect(form.errors[:file].join).to include("#{CvParsing::Settings.max_file_size_megabytes} MB")
  end
end
