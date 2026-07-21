import { Controller } from "@hotwired/stimulus"

// Shows and hides employment fields from the data the server put in the DOM, so the
// PRD section 4 rules live in one place (the job_functions and employment_types
// records) rather than being duplicated here. This controller only reads flags.
export default class extends Controller {
  static targets = [
    "jobFunction", "salary", "percentage", "revenue",
    "big", "bigNumber", "skillsFrame"
  ]

  connect() {
    this.jobFunctionChanged()
    this.employmentChanged()
    this.bigStatusChanged()
  }

  jobFunctionChanged() {
    const option = this.#selectedJobFunctionOption()
    const requiresBig = option?.dataset.requiresBig === "true"
    const revenueRelevant = option?.dataset.revenueRelevant === "true"

    this.#toggle(this.bigTarget, requiresBig)
    this.#toggle(this.revenueTarget, revenueRelevant)
    this.#refreshSkills(option?.value)
  }

  employmentChanged() {
    this.#toggle(this.salaryTarget, this.#anyEmployment("salaried"))
    this.#toggle(this.percentageTarget, this.#anyEmployment("percentage_based"))
  }

  bigStatusChanged() {
    if (!this.hasBigNumberTarget) return

    const select = this.bigTarget.querySelector("select")
    this.#toggle(this.bigNumberTarget, select?.value === "registered")
  }

  #selectedJobFunctionOption() {
    if (!this.hasJobFunctionTarget) return null
    return this.jobFunctionTarget.selectedOptions[0]
  }

  #anyEmployment(basis) {
    return this.#employmentCheckboxes().some((box) => box.checked && box.dataset.basis === basis)
  }

  #employmentCheckboxes() {
    return Array.from(this.element.querySelectorAll("input[name='candidate_profile[employment_type_ids][]']"))
  }

  #refreshSkills(jobFunctionId) {
    if (!this.hasSkillsFrameTarget || !jobFunctionId) return

    const url = new URL(this.skillsFrameTarget.dataset.skillsUrl, window.location.origin)
    url.searchParams.set("job_function_id", jobFunctionId)
    this.skillsFrameTarget.src = url.pathname + url.search
  }

  #toggle(element, visible) {
    if (!element) return

    element.hidden = !visible
    element.querySelectorAll("input, select").forEach((field) => {
      field.disabled = !visible
    })
  }
}
