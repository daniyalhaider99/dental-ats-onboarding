module CvParsing
  class MappedResult
    attr_reader :profile_attributes, :educations, :work_experiences,
                :language_names, :skill_names, :job_function, :extraction_metadata

    def initialize(profile_attributes:, educations:, work_experiences:,
                   language_names:, skill_names:, job_function:, extraction_metadata:)
      @profile_attributes = profile_attributes
      @educations = educations
      @work_experiences = work_experiences
      @language_names = language_names
      @skill_names = skill_names
      @job_function = job_function
      @extraction_metadata = extraction_metadata
    end
  end
end
