module Onboarding
  class StatusBroadcast
    def self.call(profile)
      Turbo::StreamsChannel.broadcast_replace_to(
        profile,
        target: "onboarding_body",
        partial: "onboarding/profiles/body",
        locals: { profile: profile }
      )
    rescue StandardError => e
      Rails.logger.warn("[onboarding] status broadcast failed: #{e.class}: #{e.message}")
    end
  end
end
