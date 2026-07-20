class CandidateDocument < ApplicationRecord
  CONTENT_TYPES = {
    "application/pdf" => :pdf,
    "application/msword" => :doc,
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" => :docx
  }.freeze

  belongs_to :candidate_profile, inverse_of: :candidate_documents

  has_one_attached :file

  enum :document_type, { cv: 0 }
  enum :parsing_status, { pending: 0, processing: 1, completed: 2, failed: 3 }, prefix: :parsing

  validates :original_filename, :content_type, presence: true
  validates :file_size, numericality: { only_integer: true, greater_than: 0 }
  validates :content_type, inclusion: {
    in: CONTENT_TYPES.keys,
    message: "must be a PDF, DOC or DOCX file"
  }

  scope :most_recent_first, -> { order(created_at: :desc) }

  def format
    CONTENT_TYPES.fetch(content_type)
  end

  def parsing_in_progress?
    parsing_pending? || parsing_processing?
  end

  def parsing_finished?
    parsing_completed? || parsing_failed?
  end
end
