module CurrentOnboarding
  extend ActiveSupport::Concern

  private

  def current_profile
    return @current_profile if defined?(@current_profile)

    id = session[:candidate_profile_id]
    @current_profile = id && CandidateProfile.find_by(id: id)
  end

  def require_current_profile
    return if current_profile

    redirect_to new_onboarding_cv_upload_path, alert: "Start by uploading your CV."
  end
end
