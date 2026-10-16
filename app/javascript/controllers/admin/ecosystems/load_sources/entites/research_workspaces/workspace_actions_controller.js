import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    confirm: Boolean,
    confirmMessage: String,
    busyText: String,
  }

  confirm(event) {
    if (!this.confirmValue) return

    const message =
      this.confirmMessageValue ||
      "Are you sure you want to continue?"

    if (!window.confirm(message)) {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  markBusy(event) {
    const element = event.currentTarget

    if (!(element instanceof HTMLButtonElement)) return
    if (element.disabled) {
      event.preventDefault()
      return
    }

    element.disabled = true
    element.setAttribute("aria-busy", "true")
    element.classList.add("opacity-60", "cursor-wait")

    if (this.busyTextValue) {
      element.dataset.originalText = element.textContent
      element.textContent = this.busyTextValue
    }
  }

  restore(event) {
    const element = event.currentTarget

    if (!(element instanceof HTMLButtonElement)) return

    element.disabled = false
    element.removeAttribute("aria-busy")
    element.classList.remove("opacity-60", "cursor-wait")

    if (element.dataset.originalText) {
      element.textContent = element.dataset.originalText
      delete element.dataset.originalText
    }
  }
}
