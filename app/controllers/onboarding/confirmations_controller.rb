module Onboarding
  class ConfirmationsController < ApplicationController
    def show
      @profile = completed_profile
      redirect_to root_path unless @profile
    end

    private

    def completed_profile
      id = session[:completed_profile_id]
      id && CandidateProfile.completed.find_by(id: id)
    end
  end
end
