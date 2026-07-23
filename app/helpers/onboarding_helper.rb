module OnboardingHelper
  BADGES = {
    extracted: { label: "Extracted from CV", classes: "bg-emerald-50 text-emerald-700 ring-emerald-600/20", dot: "bg-emerald-500" },
    needs_review: { label: "Please check", classes: "bg-amber-50 text-amber-700 ring-amber-600/20", dot: "bg-amber-500" },
    missing: { label: "Missing", classes: "bg-slate-100 text-slate-500 ring-slate-500/20", dot: "bg-slate-400" }
  }.freeze

  def provenance_badge(provenance, field)
    badge = BADGES.fetch(provenance.state(field))

    tag.span(class: "badge #{badge[:classes]}") do
      concat tag.span("", class: "h-1.5 w-1.5 rounded-full #{badge[:dot]}")
      concat badge[:label]
    end
  end

  def onboarding_job_functions = JobFunction.active.ordered
  def onboarding_regions = Region.active.ordered
  def onboarding_employment_types = EmploymentType.active.ordered
  def onboarding_transport_types = TransportType.active.ordered
  def onboarding_working_days = WorkingDay.active.ordered
  def onboarding_languages = Language.active.ordered

  def onboarding_search_statuses
    CandidateProfile.search_statuses.keys.map { |status| [ status.humanize, status ] }
  end

  def onboarding_big_statuses
    CandidateProfile.big_registration_statuses.keys.map { |status| [ status.humanize, status ] }
  end

  def onboarding_education_levels
    Education.levels.keys.map { |level| [ level.upcase == level ? level : level.humanize, level ] }
  end

  def onboarding_language_proficiencies
    CandidateLanguage.proficiencies.keys.map { |level| [ level.humanize, level ] }
  end

  def onboarding_skills_for(profile)
    group = profile.job_function&.skill_group
    group ? group.skills.active.ordered : Skill.none
  end

  SECTION_ICONS = {
    personal: "M12 12a5 5 0 100-10 5 5 0 000 10zm0 2c-4 0-8 2-8 5v1h16v-1c0-3-4-5-8-5z",
    preferences: "M3 6h18M7 12h10M10 18h4",
    employment: "M3 7h18v13H3zM8 7V5a2 2 0 012-2h4a2 2 0 012 2v2",
    education: "M12 3L2 8l10 5 10-5-10-5zM4 10v5c0 1.5 3.5 3 8 3s8-1.5 8-3v-5",
    work: "M3 7h18v13H3zM8 7V5a2 2 0 012-2h4a2 2 0 012 2v2M3 12h18",
    skills: "M12 2l2.4 5.6L20 8l-4.5 3.9L17 18l-5-3-5 3 1.5-6.1L4 8l5.6-.4z",
    availability: "M8 2v3M16 2v3M4 8h16M4 6h16v14H4zM9 13h2v2H9z",
    additional: "M4 5h16M4 10h16M4 15h10"
  }.freeze

  def onboarding_section_header(title, icon)
    tag.h2(class: "section-title") do
      concat(tag.span(class: "section-accent") do
        tag.svg(class: "h-4 w-4", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "1.8", "stroke-linecap": "round", "stroke-linejoin": "round") do
          tag.path(d: SECTION_ICONS.fetch(icon))
        end
      end)
      concat title
    end
  end

  def onboarding_step_indicator(current)
    steps = { 1 => "Upload CV", 2 => "Review profile" }
    connector = tag.span("", class: "h-0.5 w-10 rounded-full bg-slate-200")
    safe_join(steps.map { |number, label| step_pill(number, label, current) }, connector)
  end

  private

  def step_pill(number, label, current)
    state = number < current ? :done : (number == current ? :active : :upcoming)

    circle_classes = {
      done: "bg-brand-600 text-white",
      active: "bg-brand-600 text-white ring-4 ring-brand-100",
      upcoming: "border border-slate-300 bg-white text-slate-400"
    }.fetch(state)

    text_classes = state == :upcoming ? "text-slate-400" : "font-semibold text-slate-900"

    tag.span(class: "flex items-center gap-2 text-sm #{text_classes}") do
      concat(tag.span(class: "flex h-7 w-7 items-center justify-center rounded-full text-xs font-semibold #{circle_classes}") do
        state == :done ? checkmark_icon : number.to_s
      end)
      concat label
    end
  end

  def checkmark_icon
    tag.svg(class: "h-4 w-4", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "3", "stroke-linecap": "round", "stroke-linejoin": "round") do
      tag.path(d: "M20 6L9 17l-5-5")
    end
  end
end
