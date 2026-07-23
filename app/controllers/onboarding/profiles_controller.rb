module Onboarding
  class ProfilesController < ApplicationController
    include CurrentOnboarding

    before_action :require_current_profile
    before_action :fail_stalled_parsing, only: %i[show status]

    def show
      @profile = current_profile
      @document = @profile.latest_cv
    end

    def status
      document = current_profile.latest_cv

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "onboarding_body",
            partial: "onboarding/profiles/body",
            locals: { profile: current_profile }
          )
        end
        format.html { head :no_content }
      end
    end

    def skills
      job_function = JobFunction.active.find_by(id: params[:job_function_id])
      render partial: "onboarding/profiles/sections/skills",
             locals: { profile: current_profile, job_function: job_function }
    end

    def update
      @profile = current_profile
      result = CandidateProfiles::Complete.call(profile: @profile, params: profile_params)

      if result.success?
        reset_session
        redirect_to onboarding_cv_upload_path, notice: "Your profile has been submitted. Thank you."
      else
        @document = @profile.latest_cv
        render :show, status: :unprocessable_entity
      end
    end

    private

    def fail_stalled_parsing
      current_profile.latest_cv&.fail_as_stalled!
    end

    def profile_params
      params.require(:candidate_profile).permit(
        :first_name, :last_name, :email, :phone, :city, :country,
        :job_function_id, :search_status, :max_travel_time_minutes, :reason_for_looking,
        :desired_gross_salary, :desired_percentage, :average_daily_revenue,
        :big_registration_status, :big_number, :years_of_experience,
        :available_from, :notice_period, :motivation, :internal_notes,
        :professional_summary, :consent,
        region_ids: [], employment_type_ids: [], transport_type_ids: [],
        working_day_ids: [], skill_ids: [], language_ids: [],
        educations_attributes: %i[id institution study city_and_country level start_date end_date position _destroy],
        work_experiences_attributes: %i[id job_title company_name responsibilities start_date end_date current_job position _destroy]
      )
    end
  end
end
