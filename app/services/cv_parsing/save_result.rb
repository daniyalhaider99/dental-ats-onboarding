module CvParsing
  class SaveResult
    def self.call(profile:, mapped:)
      new(profile: profile, mapped: mapped).call
    end

    def initialize(profile:, mapped:)
      @profile = profile
      @mapped = mapped
    end

    def call
      CandidateProfile.transaction do
        profile.assign_attributes(mapped.profile_attributes)
        profile.extraction_metadata = mapped.extraction_metadata
        replace_educations
        replace_work_experiences
        replace_languages
        replace_skills
        profile.save!(validate: false)
      end

      ServiceResult.success(profile)
    end

    private

    attr_reader :profile, :mapped

    def replace_educations
      profile.educations.destroy_all
      mapped.educations.each { |attributes| profile.educations.build(attributes) }
    end

    def replace_work_experiences
      profile.work_experiences.destroy_all
      mapped.work_experiences.each { |attributes| profile.work_experiences.build(attributes) }
    end

    def replace_languages
      profile.candidate_languages.destroy_all
      languages_by_name.values_at(*normalized_language_keys).compact.uniq.each do |language|
        profile.candidate_languages.build(language: language)
      end
    end

    def replace_skills
      profile.candidate_skills.destroy_all
      matches = Skills::Matcher.call(names: mapped.skill_names, skill_group: mapped.job_function&.skill_group)

      seen_skill_ids = []
      seen_suggestions = []

      matches.each do |match|
        if match.matched?
          next if seen_skill_ids.include?(match.skill.id)

          seen_skill_ids << match.skill.id
          profile.candidate_skills.build(skill: match.skill, source: :cv)
        else
          key = match.suggestion.downcase
          next if seen_suggestions.include?(key)

          seen_suggestions << key
          profile.candidate_skills.build(free_text_suggestion: match.suggestion, source: :cv)
        end
      end
    end

    def languages_by_name
      @languages_by_name ||= Language.active.index_by { |language| language.name.downcase }
    end

    def normalized_language_keys
      mapped.language_names.map { |name| name.downcase }.uniq
    end
  end
end
