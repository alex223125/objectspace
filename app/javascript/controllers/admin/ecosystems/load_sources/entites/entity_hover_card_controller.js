
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.hideTimeout = null
  }

  disconnect() {
    this.cancelHide()
  }

  show() {
    this.cancelHide()

    this.cardTarget.classList.remove("hidden")
    this.cardTarget.setAttribute("aria-hidden", "false")
  }

  hide(event) {
    // Keep the card open while focus remains inside the wrapper.
    if (event?.relatedTarget && this.element.contains(event.relatedTarget)) {
      return
    }

    this.cancelHide()

    this.hideTimeout = window.setTimeout(() => {
      if (!this.element.matches(":hover") &&
          !this.element.contains(document.activeElement)) {
        this.cardTarget.classList.add("hidden")
        this.cardTarget.setAttribute("aria-hidden", "true")
      }
    }, 120)
  }

  cancelHide() {
    if (this.hideTimeout !== null) {
      window.clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }
  }
}