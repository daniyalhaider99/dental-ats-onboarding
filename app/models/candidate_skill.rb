class CandidateSkill < ApplicationRecord
  belongs_to :candidate_profile, inverse_of: :candidate_skills
  belongs_to :skill, optional: true, inverse_of: :candidate_skills

  enum :source, { manual: 0, cv: 1 }, prefix: :source

  validates :free_text_suggestion, presence: true, if: -> { skill_id.blank? }
  validates :free_text_suggestion, absence: {
    message: "cannot be set on a matched skill"
  }, if: -> { skill_id.present? }
  validates :skill_id, uniqueness: { scope: :candidate_profile_id }, allow_nil: true

  scope :matched,   -> { where.not(skill_id: nil) }
  scope :suggested, -> { where(skill_id: nil) }

  def display_name
    skill&.name || free_text_suggestion
  end
end
