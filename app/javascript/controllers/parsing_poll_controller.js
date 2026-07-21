import { Controller } from "@hotwired/stimulus"

// Fallback for when the Turbo Stream subscription does not deliver (no WebSocket,
// a dropped connection). Polls the status endpoint, which re-renders the body via a
// Turbo Stream, and stops once parsing is no longer in progress.
export default class extends Controller {
  static targets = ["body"]
  static values = { url: String, interval: { type: Number, default: 2500 } }

  connect() {
    if (this.#inProgress()) this.#start()
  }

  disconnect() {
    this.#stop()
  }

  #start() {
    this.timer = setInterval(() => this.#poll(), this.intervalValue)
  }

  #stop() {
    if (this.timer) clearInterval(this.timer)
  }

  async #poll() {
    if (!this.#inProgress()) return this.#stop()

    const response = await fetch(this.urlValue, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })

    if (response.ok) {
      const stream = await response.text()
      Turbo.renderStreamMessage(stream)
    }
  }

  #inProgress() {
    return this.hasBodyTarget && this.bodyTarget.dataset.inProgress === "true"
  }
}
