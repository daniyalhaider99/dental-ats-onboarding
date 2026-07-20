class User < ApplicationRecord
  has_one :candidate_profile, dependent: :nullify, inverse_of: :user

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
