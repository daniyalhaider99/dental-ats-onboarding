class Education < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :educations

  enum :level, { mbo: 0, hbo: 1, bachelor: 2, master: 3, doctor: 4, course: 5 }

  validates :study, presence: true
  validate  :end_date_cannot_precede_start_date

  scope :ordered, -> { order(:position, :created_at) }

  private

  def end_date_cannot_precede_start_date
    return if start_date.blank? || end_date.blank? || end_date >= start_date

    errors.add(:end_date, "cannot be earlier than the start date")
  end
end
