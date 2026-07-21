module CandidateProfiles
  class FieldProvenance
    STATES = %i[extracted needs_review missing].freeze

    def initialize(profile)
      @metadata = profile.extraction_metadata || {}
    end

    def state(field)
      entry = @metadata[field.to_s]
      return :missing if entry.blank?
      return :needs_review if entry["needs_review"]

      :extracted
    end

    def extracted?(field) = state(field) == :extracted
    def needs_review?(field) = state(field) == :needs_review
    def missing?(field) = state(field) == :missing
  end
end
