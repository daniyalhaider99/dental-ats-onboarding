module OnboardingHelper
  BADGES = {
    extracted: { label: "Extracted from CV", classes: "bg-emerald-50 text-emerald-700 ring-emerald-600/20" },
    needs_review: { label: "Please check", classes: "bg-amber-50 text-amber-700 ring-amber-600/20" },
    missing: { label: "Missing", classes: "bg-slate-100 text-slate-500 ring-slate-500/20" }
  }.freeze

  def provenance_badge(provenance, field)
    badge = BADGES.fetch(provenance.state(field))

    tag.span(
      badge[:label],
      class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium " \
             "ring-1 ring-inset #{badge[:classes]}"
    )
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

  def onboarding_step_indicator(current)
    steps = { 1 => "Upload CV", 2 => "Review profile" }
    safe_join(steps.map { |number, label| step_pill(number, label, current) }, tag.span("", class: "h-px w-8 bg-slate-300"))
  end

  private

  def step_pill(number, label, current)
    done = number <= current
    circle_classes = done ? "bg-slate-900 text-white" : "border border-slate-300 text-slate-400"
    text_classes = done ? "font-medium text-slate-900" : "text-slate-400"

    tag.span(class: "flex items-center gap-2 text-sm #{text_classes}") do
      concat tag.span(number, class: "flex h-6 w-6 items-center justify-center rounded-full text-xs #{circle_classes}")
      concat label
    end
  end
end
