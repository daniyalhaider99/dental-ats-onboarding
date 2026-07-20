module Onboarding
  class UploadForm
    include ActiveModel::Model

    OLE_EQUIVALENTS = [
      "application/x-ole-storage",
      "application/vnd.ms-office",
      "application/x-cfb"
    ].freeze

    attr_accessor :file, :consent

    validates :consent, acceptance: { accept: [ "1", true ] }
    validate :file_must_be_present
    validate :file_must_be_a_supported_type, if: -> { file.present? }
    validate :file_must_be_within_size_limit, if: -> { file.present? }

    def consented?
      ActiveModel::Type::Boolean.new.cast(consent).present?
    end

    def content_type
      return if file.blank?

      @content_type ||= normalize(detect_from_bytes)
    end

    def original_filename
      file&.original_filename
    end

    def file_size
      file&.size
    end

    private

    def detect_from_bytes
      file.tempfile.rewind
      Marcel::MimeType.for(file.tempfile)
    ensure
      file.tempfile.rewind
    end

    def normalize(detected)
      OLE_EQUIVALENTS.include?(detected) ? "application/msword" : detected
    end

    def file_must_be_present
      errors.add(:file, "must be selected") if file.blank?
    end

    def file_must_be_a_supported_type
      return if CvParsing::Settings.accepted_content_types.include?(content_type)

      errors.add(:file, "must be a PDF, DOC or DOCX file")
    end

    def file_must_be_within_size_limit
      return if file_size.to_i <= CvParsing::Settings.max_file_size

      errors.add(
        :file,
        "must be smaller than #{CvParsing::Settings.max_file_size_megabytes} MB"
      )
    end
  end
end
