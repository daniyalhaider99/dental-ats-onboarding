module Admin
  class CandidateCvsController < BaseController
    def show
      profile = CandidateProfile.find(params[:candidate_id])
      document = profile.latest_cv

      unless document&.file&.attached?
        return redirect_to admin_candidate_path(profile), alert: "No CV is attached to this candidate."
      end

      policy = CandidateDocumentPolicy.new(actor: current_actor, document: document)
      return head :forbidden unless policy.download?

      redirect_to rails_blob_path(document.file, disposition: "inline"), allow_other_host: false
    end
  end
end
