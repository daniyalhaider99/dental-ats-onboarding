class WorkExperience < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :work_experiences

  validates :job_title, :company_name, presence: true
  validate :end_date_cannot_precede_start_date
  validate :current_job_cannot_have_end_date

  scope :ordered, -> { order(:position, :created_at) }

  private

  def end_date_cannot_precede_start_date
    return if start_date.blank? || end_date.blank? || end_date >= start_date

    errors.add(:end_date, "cannot be earlier than the start date")
  end

  def current_job_cannot_have_end_date
    return unless current_job? && end_date.present?

    errors.add(:end_date, "must be blank for a job you currently hold")
  end
end
