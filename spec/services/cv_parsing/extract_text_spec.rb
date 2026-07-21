require "rails_helper"

RSpec.describe CvParsing::ExtractText do
  def document_for(fixture, content_type)
    profile = create(:candidate_profile)
    document = profile.candidate_documents.build(
      document_type: :cv, original_filename: fixture, content_type: content_type, file_size: 1, parsing_status: :pending
    )
    document.file.attach(io: File.open(cv_fixture_path(fixture)), filename: fixture, content_type: content_type)
    document.save!
    document
  end

  it "extracts text from a PDF" do
    result = described_class.call(document_for("sample.pdf", "application/pdf"))
    expect(result).to be_success
    expect(result.value).to include("Anna de Vries")
  end

  it "extracts text from a DOCX" do
    result = described_class.call(document_for("sample.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"))
    expect(result).to be_success
    expect(result.value).to include("Anna de Vries")
  end

  it "returns a failure result when a PDF has no extractable text" do
    profile = create(:candidate_profile)
    document = profile.candidate_documents.build(
      document_type: :cv, original_filename: "empty.pdf", content_type: "application/pdf", file_size: 1, parsing_status: :pending
    )
    document.file.attach(io: StringIO.new("%PDF-1.4\n%%EOF\n"), filename: "empty.pdf", content_type: "application/pdf")
    document.save!

    expect(described_class.call(document)).to be_failure
  end
end
