import { Controller } from "@hotwired/stimulus"

// When a work experience is marked as the current job, its end date makes no sense,
// so the field is cleared and disabled. This mirrors the model and database rule
// that a current job cannot carry an end date.
export default class extends Controller {
  static targets = ["checkbox", "endDate"]

  connect() {
    this.toggle()
  }

  toggle() {
    const input = this.endDateTarget.querySelector("input")
    if (!input) return

    if (this.checkboxTarget.checked) {
      input.value = ""
      input.disabled = true
      this.endDateTarget.classList.add("opacity-50")
    } else {
      input.disabled = false
      this.endDateTarget.classList.remove("opacity-50")
    }
  }
}
