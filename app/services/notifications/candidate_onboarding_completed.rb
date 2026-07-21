module Notifications
  class CandidateOnboardingCompleted
    EVENT = "candidate_onboarding_completed".freeze

    def self.call(profile)
      new(profile).call
    end

    def initialize(profile)
      @profile = profile
    end

    def call
      Rails.logger.info(
        "[#{EVENT}] candidate_profile_id=#{profile.id} " \
        "name=#{profile.full_name.inspect} email=#{profile.email.inspect}"
      )
      AdminMailer.candidate_completed(profile).deliver_later
      ServiceResult.success(profile)
    rescue StandardError => e
      Rails.logger.error("[#{EVENT}] notification failed: #{e.class}: #{e.message}")
      ServiceResult.failure(e.message)
    end

    private

    attr_reader :profile
  end
end
