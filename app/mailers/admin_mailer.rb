class AdminMailer < ApplicationMailer
  def candidate_completed(profile)
    @profile = profile
    recipient = Rails.application.config.x.recruitment_inbox

    mail(to: recipient, subject: "New candidate profile: #{profile.full_name || profile.email}")
  end
end
