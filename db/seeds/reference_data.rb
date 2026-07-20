module Seeds
  module ReferenceData
    SKILL_GROUPS = [
      { slug: "dentist",           name: "Dentist" },
      { slug: "dental_hygienist",  name: "Dental hygienist" },
      { slug: "dental_assistant",  name: "Dental assistant" },
      { slug: "front_office",      name: "Front office" },
      { slug: "practice_manager",  name: "Practice manager" },
      { slug: "dental_technician", name: "Dental technician" }
    ].freeze

    JOB_FUNCTIONS = [
      { slug: "general_dentist",           name: "General dentist",           skill_group: "dentist",           requires_big: true,  revenue: true },
      { slug: "specialist",                name: "Specialist",                skill_group: "dentist",           requires_big: true,  revenue: true },
      { slug: "dental_hygienist",          name: "Dental hygienist",          skill_group: "dental_hygienist",  requires_big: true,  revenue: true },
      { slug: "prevention_assistant",      name: "Prevention assistant",      skill_group: "dental_assistant",  requires_big: false, revenue: true },
      { slug: "paro_prevention_assistant", name: "Paro-prevention assistant", skill_group: "dental_assistant",  requires_big: false, revenue: false },
      { slug: "dental_assistant",          name: "Dental assistant",          skill_group: "dental_assistant",  requires_big: false, revenue: false },
      { slug: "orthodontic_assistant",     name: "Orthodontic assistant",     skill_group: "dental_assistant",  requires_big: false, revenue: false },
      { slug: "front_office",              name: "Front-office / receptionist", skill_group: "front_office",    requires_big: false, revenue: false },
      { slug: "practice_manager",          name: "Practice manager",          skill_group: "practice_manager",  requires_big: false, revenue: false },
      { slug: "dental_technician",         name: "Dental technician",         skill_group: "dental_technician", requires_big: false, revenue: false }
    ].freeze

    SKILLS = {
      "dentist" => [
        "Endodontics", "Restorative dentistry", "Pediatric dentistry", "Surgery",
        "Aligners", "Implantology", "Periodontology", "Prosthetics"
      ],
      "dental_hygienist" => [
        "Periodontology", "Prevention", "Scaling", "Patient education",
        "Root planing", "Fluoride treatment"
      ],
      "dental_assistant" => [
        "Chairside assistance", "Sterilization", "Orthodontics", "Prevention",
        "Radiography", "Patient intake"
      ],
      "front_office" => [
        "Planning", "Phone handling", "Invoicing", "Patient communication",
        "Practice software", "Appointment management"
      ],
      "practice_manager" => [
        "Team management", "Scheduling", "HR", "Practice operations",
        "Finance", "Quality assurance"
      ],
      "dental_technician" => [
        "Prosthetics", "CAD/CAM", "Crown and bridge work", "Dentures",
        "Ceramics", "Orthodontic appliances"
      ]
    }.freeze

    EMPLOYMENT_TYPES = [
      { slug: "employed",         name: "Employed",                    basis: :salaried },
      { slug: "temporary",        name: "Temporary contract",          basis: :salaried },
      { slug: "freelance_zzp",    name: "Freelance / ZZP",             basis: :percentage_based },
      { slug: "percentage_based", name: "Percentage-based",            basis: :percentage_based },
      { slug: "locum",            name: "Locum / waarneming",          basis: :percentage_based }
    ].freeze

    REGIONS = [
      "Drenthe", "Flevoland", "Friesland", "Gelderland", "Groningen", "Limburg",
      "Noord-Brabant", "Noord-Holland", "Overijssel", "Utrecht", "Zeeland",
      "Zuid-Holland"
    ].freeze

    TRANSPORT_TYPES = [ "Bike", "Scooter", "Public transport", "Car" ].freeze

    WORKING_DAYS = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze

    LANGUAGES = [
      "Dutch", "English", "German", "French", "Spanish", "Polish", "Turkish",
      "Arabic", "Portuguese", "Italian"
    ].freeze

    class << self
      def call
        ActiveRecord::Base.transaction do
          seed_simple(Region, REGIONS)
          seed_simple(TransportType, TRANSPORT_TYPES)
          seed_simple(WorkingDay, WORKING_DAYS)
          seed_simple(Language, LANGUAGES)
          seed_employment_types
          seed_skill_groups
          seed_skills
          seed_job_functions
        end
      end

      private

      def seed_simple(model, names)
        names.each_with_index do |name, index|
          model.find_or_initialize_by(slug: slugify(name)).update!(name: name, position: index)
        end
      end

      def seed_employment_types
        EMPLOYMENT_TYPES.each_with_index do |attrs, index|
          EmploymentType.find_or_initialize_by(slug: attrs[:slug])
                        .update!(name: attrs[:name], compensation_basis: attrs[:basis], position: index)
        end
      end

      def seed_skill_groups
        SKILL_GROUPS.each_with_index do |attrs, index|
          SkillGroup.find_or_initialize_by(slug: attrs[:slug])
                    .update!(name: attrs[:name], position: index)
        end
      end

      def seed_skills
        SKILLS.each do |group_slug, names|
          group = SkillGroup.find_by!(slug: group_slug)

          names.each_with_index do |name, index|
            Skill.find_or_initialize_by(skill_group: group, slug: slugify(name))
                 .update!(name: name, position: index)
          end
        end
      end

      def seed_job_functions
        JOB_FUNCTIONS.each_with_index do |attrs, index|
          JobFunction.find_or_initialize_by(slug: attrs[:slug]).update!(
            name: attrs[:name],
            skill_group: SkillGroup.find_by!(slug: attrs[:skill_group]),
            requires_big_registration: attrs[:requires_big],
            revenue_relevant: attrs[:revenue],
            position: index
          )
        end
      end

      def slugify(name)
        name.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
      end
    end
  end
end
