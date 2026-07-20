import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "hint"]
  static values = { maxSize: Number }

  dragOver(event) {
    event.preventDefault()
    this.dropzoneTarget.classList.add("border-slate-900", "bg-slate-50")
  }

  dragLeave(event) {
    event.preventDefault()
    this.#resetDropzone()
  }

  drop(event) {
    event.preventDefault()
    this.#resetDropzone()

    const [file] = event.dataTransfer.files
    if (!file) return

    this.inputTarget.files = event.dataTransfer.files
    this.#describe(file)
  }

  fileSelected() {
    const [file] = this.inputTarget.files
    if (file) this.#describe(file)
  }

  #describe(file) {
    const megabytes = (file.size / 1024 / 1024).toFixed(1)

    if (this.hasMaxSizeValue && file.size > this.maxSizeValue) {
      this.hintTarget.textContent = `${file.name} is ${megabytes} MB, which is over the limit.`
      this.hintTarget.classList.add("text-red-600")
    } else {
      this.hintTarget.textContent = `${file.name} (${megabytes} MB)`
      this.hintTarget.classList.remove("text-red-600")
    }
  }

  #resetDropzone() {
    this.dropzoneTarget.classList.remove("border-slate-900", "bg-slate-50")
  }
}
