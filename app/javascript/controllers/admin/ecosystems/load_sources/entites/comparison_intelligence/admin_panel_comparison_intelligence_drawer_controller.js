import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "opener", "closeButton"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  open() {
    if (!this.hasPanelTarget) return
    this.panelTarget.hidden = false
    this.panelTarget.setAttribute("aria-hidden", "false")
    this.openerTarget?.setAttribute("aria-expanded", "true")
    document.addEventListener("keydown", this.onKeydown)
    ;(this.hasCloseButtonTarget ? this.closeButtonTarget : this.panelTarget).focus?.()
  }

  close() {
    if (!this.hasPanelTarget) return
    this.panelTarget.hidden = true
    this.panelTarget.setAttribute("aria-hidden", "true")
    this.openerTarget?.setAttribute("aria-expanded", "false")
    document.removeEventListener("keydown", this.onKeydown)
    this.openerTarget?.focus()
  }

  toggle() {
    if (this.hasPanelTarget && !this.panelTarget.hidden) this.close()
    else this.open()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }
}
