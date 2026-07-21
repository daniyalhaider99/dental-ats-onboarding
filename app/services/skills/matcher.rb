module Skills
  class Matcher
    Match = Struct.new(:skill, :suggestion, keyword_init: true) do
      def matched? = skill.present?
    end

    def self.call(names:, skill_group:)
      new(skill_group: skill_group).call(names)
    end

    def initialize(skill_group:)
      @skill_group = skill_group
      @index = build_index
    end

    def call(names)
      Array(names).filter_map { |name| match(name) }
    end

    def match(name)
      normalized = normalize(name)
      return if normalized.blank?

      skill = @index[normalized]
      if skill
        Match.new(skill: skill)
      else
        Match.new(suggestion: name.to_s.strip)
      end
    end

    private

    attr_reader :skill_group

    def build_index
      return {} if skill_group.nil?

      skill_group.skills.active.each_with_object({}) do |skill, index|
        index[normalize(skill.name)] = skill
        index[normalize(skill.slug)] = skill
      end
    end

    def normalize(value)
      value.to_s.downcase.gsub(/[^a-z0-9]+/, " ").squish
    end
  end
end
