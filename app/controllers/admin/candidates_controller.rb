module Admin
  class CandidatesController < BaseController
    def index
      @profiles = CandidateProfile
                  .includes(:job_function, candidate_documents: { file_attachment: :blob })
                  .most_recent_first
    end

    def show
      @profile = CandidateProfile
                 .includes(:job_function, :skills, :languages, :regions, :employment_types,
                           :working_days, :transport_types, :educations, :work_experiences,
                           candidate_skills: :skill)
                 .find(params[:id])
      @document = @profile.latest_cv
    end
  end
end
