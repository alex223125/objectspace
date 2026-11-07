import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "opener"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  open() {
    if (!this.hasDialogTarget) return
    this.dialogTarget.hidden = false
    this.dialogTarget.setAttribute("aria-hidden", "false")
    this.openerTarget?.setAttribute("aria-expanded", "true")
    document.addEventListener("keydown", this.onKeydown)
    this.dialogTarget.querySelector(
      "button, input, select, textarea, [tabindex]:not([tabindex='-1'])"
    )?.focus()
  }

  close() {
    if (!this.hasDialogTarget) return
    this.dialogTarget.hidden = true
    this.dialogTarget.setAttribute("aria-hidden", "true")
    this.openerTarget?.setAttribute("aria-expanded", "false")
    document.removeEventListener("keydown", this.onKeydown)
    this.openerTarget?.focus()
  }

  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }
}
