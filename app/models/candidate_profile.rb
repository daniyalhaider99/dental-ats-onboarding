class CandidateProfile < ApplicationRecord
  REVIEW = :onboarding_review

  belongs_to :user,         optional: true, inverse_of: :candidate_profile
  belongs_to :job_function, optional: true, inverse_of: :candidate_profiles

  has_many :candidate_documents, dependent: :destroy, inverse_of: :candidate_profile
  has_many :educations,        -> { ordered }, dependent: :destroy, inverse_of: :candidate_profile
  has_many :work_experiences,  -> { ordered }, dependent: :destroy, inverse_of: :candidate_profile

  has_many :candidate_skills,    dependent: :destroy, inverse_of: :candidate_profile
  has_many :skills, through: :candidate_skills
  has_many :candidate_languages, dependent: :destroy, inverse_of: :candidate_profile
  has_many :languages, through: :candidate_languages

  has_many :candidate_profile_regions,          dependent: :destroy, inverse_of: :candidate_profile
  has_many :candidate_profile_employment_types, dependent: :destroy, inverse_of: :candidate_profile
  has_many :candidate_profile_transport_types,  dependent: :destroy, inverse_of: :candidate_profile
  has_many :candidate_profile_working_days,     dependent: :destroy, inverse_of: :candidate_profile

  has_many :regions,          through: :candidate_profile_regions
  has_many :employment_types, through: :candidate_profile_employment_types
  has_many :transport_types,  through: :candidate_profile_transport_types
  has_many :working_days,     through: :candidate_profile_working_days

  accepts_nested_attributes_for :educations,       allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :work_experiences, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :candidate_languages, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :candidate_skills,    allow_destroy: true, reject_if: :all_blank

  enum :status,        { draft: 0, completed: 1 }
  enum :search_status, { active: 0, passive: 1, inactive: 2 }, prefix: :searching
  enum :big_registration_status,
       { registered: 0, in_progress: 1, under_supervision: 2, not_applicable: 3 },
       prefix: :big

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :desired_percentage,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_nil: true
  validates :desired_gross_salary, :average_daily_revenue,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_travel_time_minutes, :years_of_experience,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate  :phone_must_be_dialable, if: -> { phone.present? }

  with_options on: REVIEW do
    validates :first_name, :last_name, :email, :phone, :city, presence: true
    validates :job_function, :search_status, presence: true
    validates :max_travel_time_minutes, :years_of_experience, :available_from, presence: true
    validates :consented_at, presence: {
      message: "must be given before the profile can be saved"
    }

    validates :big_registration_status, presence: true, if: :big_registration_relevant?
    validates :big_number, presence: true, if: :big_number_required?

    validate :at_least_one_region
    validate :at_least_one_employment_type
    validate :at_least_one_working_day
    validate :at_least_one_language
  end

  scope :most_recent_first, -> { order(created_at: :desc) }

  def full_name
    [ first_name, last_name ].compact_blank.join(" ").presence
  end

  def big_registration_relevant?
    job_function&.requires_big_registration?
  end

  def revenue_relevant?
    job_function&.revenue_relevant?
  end

  def salary_relevant?
    employment_types.any?(&:basis_salaried?)
  end

  def percentage_relevant?
    employment_types.any?(&:basis_percentage_based?)
  end

  def big_number_required?
    big_registration_relevant? && big_registered?
  end

  def latest_cv
    candidate_documents.select(&:cv?).max_by(&:created_at)
  end

  private

  def phone_must_be_dialable
    return if Phonelib.valid?(phone)

    errors.add(:phone, "is not a valid phone number")
  end

  def at_least_one_region
    errors.add(:regions, "must include at least one") if regions.empty?
  end

  def at_least_one_employment_type
    errors.add(:employment_types, "must include at least one") if employment_types.empty?
  end

  def at_least_one_working_day
    errors.add(:working_days, "must include at least one") if working_days.empty?
  end

  def at_least_one_language
    errors.add(:languages, "must include at least one") if candidate_languages.reject(&:marked_for_destruction?).empty?
  end
end
