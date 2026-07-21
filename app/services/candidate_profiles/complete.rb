module CandidateProfiles
  class Complete
    def self.call(profile:, params:)
      new(profile: profile, params: params).call
    end

    def initialize(profile:, params:)
      @profile = profile
      @params = params
    end

    def call
      assign_consent
      profile.assign_attributes(attributes)
      profile.status = :completed

      return ServiceResult.failure(profile.errors) unless profile.valid?(CandidateProfile::REVIEW)

      CandidateProfile.transaction do
        profile.user = link_user
        profile.save!(context: CandidateProfile::REVIEW)
      end

      notify
      ServiceResult.success(profile)
    rescue ActiveRecord::RecordInvalid
      ServiceResult.failure(profile.errors)
    end

    private

    attr_reader :profile, :params

    def attributes
      params.except(:consent)
    end

    def assign_consent
      return unless AttributeCoercion.boolean(params[:consent])

      profile.consented_at ||= Time.current
    end

    def link_user
      return profile.user if profile.user
      return if profile.email.blank?

      User.find_or_create_by!(email: profile.email)
    end

    def notify
      Notifications::CandidateOnboardingCompleted.call(profile)
    end
  end
end
