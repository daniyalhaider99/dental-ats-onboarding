import { Controller } from "@hotwired/stimulus"

// Adds and removes nested records (education, work experience) client-side using a
// <template> whose child_index placeholder is swapped for a unique key. Existing
// records are hidden and flagged with _destroy so Rails removes them on save; new
// unsaved rows are simply detached.
export default class extends Controller {
  static targets = ["target", "template", "row"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.#key())
    this.targetTarget.insertAdjacentHTML("beforeend", html)
    this.#reindex()
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-nested-form-target='row']")
    if (!row) return

    const idField = row.querySelector("input[name*='[id]']")
    const destroyField = row.querySelector("input[name*='_destroy']")

    if (idField && idField.value && destroyField) {
      destroyField.value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }

    this.#reindex()
  }

  #reindex() {
    let position = 0
    this.rowTargets.forEach((row) => {
      if (row.classList.contains("hidden")) return

      const field = row.querySelector("input[name*='[position]']")
      if (field) field.value = position
      position += 1
    })
  }

  #key() {
    return new Date().getTime().toString()
  }
}
