class JobFunction < ReferenceRecord
  belongs_to :skill_group, inverse_of: :job_functions

  has_many :candidate_profiles, dependent: :restrict_with_error, inverse_of: :job_function

  validates :slug, uniqueness: true

  scope :requiring_big, -> { where(requires_big_registration: true) }

  def form_rules
    {
      requiresBigRegistration: requires_big_registration,
      revenueRelevant: revenue_relevant,
      skillGroupId: skill_group_id
    }
  end
end
