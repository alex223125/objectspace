import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "progress", "status"]

  dismiss() {
    if (this.hasPanelTarget) this.panelTarget.hidden = true
    else this.element.hidden = true
  }

  reveal() {
    if (this.hasPanelTarget) this.panelTarget.hidden = false
    else this.element.hidden = false
  }

  announce(event) {
    if (!this.hasStatusTarget) return
    const message = event.currentTarget.dataset.message
    this.statusTarget.textContent = message || "Achievement details opened."
  }
}
