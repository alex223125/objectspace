import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "format", "status", "submit"]

  formatChanged() {
    if (!this.hasFormatTarget || !this.hasStatusTarget) return
    this.statusTarget.textContent = `Selected export format: ${this.formatTarget.value || "not selected"}.`
  }

  submit(event) {
    if (this.hasFormTarget && !this.formTarget.checkValidity()) {
      event?.preventDefault()
      this.formTarget.reportValidity()
      return
    }
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = "Preparing export…"
      this.statusTarget.setAttribute("role", "status")
    }
    if (this.hasSubmitTarget) this.submitTarget.disabled = true
  }

  reset() {
    if (this.hasSubmitTarget) this.submitTarget.disabled = false
    if (this.hasStatusTarget) this.statusTarget.textContent = ""
  }
}
