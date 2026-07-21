module Onboarding
  class CvUploadsController < ApplicationController
    def new
      @upload_form = Onboarding::UploadForm.new
    end

    def create
      @upload_form = Onboarding::UploadForm.new(upload_params)

      return render :new, status: :unprocessable_entity if @upload_form.invalid?

      result = CandidateProfiles::Create.call(upload_form: @upload_form)

      if result.success?
        session[:candidate_profile_id] = result.value.candidate_profile_id
        redirect_to onboarding_profile_path
      else
        @upload_form.errors.add(:base, result.error)
        render :new, status: :unprocessable_entity
      end
    end

    private

    def upload_params
      params.expect(onboarding_upload_form: [ :file, :consent ])
    end
  end
end
