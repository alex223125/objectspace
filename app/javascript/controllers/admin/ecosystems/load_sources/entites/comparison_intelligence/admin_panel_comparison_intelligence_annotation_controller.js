import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status", "thread", "input"]

  submit(event) {
    if (!this.hasFormTarget) return
    if (!this.formTarget.checkValidity()) {
      event?.preventDefault()
      this.formTarget.reportValidity()
      return
    }
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = "Submitting annotation…"
      this.statusTarget.setAttribute("role", "status")
    }
  }

  clear() {
    if (this.hasInputTarget) this.inputTarget.value = ""
    this.inputTarget?.focus()
  }

  focusInput() {
    if (this.hasInputTarget) this.inputTarget.focus()
  }
}
