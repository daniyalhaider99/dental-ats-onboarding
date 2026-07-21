module CandidateProfiles
  class Create
    def self.call(upload_form:)
      new(upload_form: upload_form).call
    end

    def initialize(upload_form:)
      @upload_form = upload_form
    end

    def call
      document = nil

      ActiveRecord::Base.transaction do
        profile = CandidateProfile.create!(status: :draft, consented_at: Time.current)
        document = build_document(profile)
        attach_file(document)
      end

      ParseCandidateCvJob.perform_later(document)

      ServiceResult.success(document)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.failure(e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :upload_form

    def build_document(profile)
      profile.candidate_documents.create!(
        document_type: :cv,
        original_filename: upload_form.original_filename,
        content_type: upload_form.content_type,
        file_size: upload_form.file_size,
        parsing_status: :pending
      )
    end

    def attach_file(document)
      upload_form.file.tempfile.rewind

      document.file.attach(
        io: upload_form.file.tempfile,
        filename: upload_form.original_filename,
        content_type: upload_form.content_type
      )
    end
  end
end
