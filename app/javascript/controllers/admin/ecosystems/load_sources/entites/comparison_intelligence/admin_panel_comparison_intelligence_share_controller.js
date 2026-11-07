import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "status"]

  async copy(event) {
    event?.preventDefault()
    const value = this.hasUrlTarget
      ? (this.urlTarget.value || this.urlTarget.textContent).trim()
      : window.location.href

    try {
      await navigator.clipboard.writeText(value)
      this.announce("Link copied to clipboard.")
    } catch {
      if (this.hasUrlTarget && this.urlTarget.select) {
        this.urlTarget.select()
        this.announce("Select and copy the link manually.")
      } else {
        this.announce("Clipboard access is unavailable. Copy the page URL from your browser.")
      }
    }
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.setAttribute("role", "status")
    }
  }
}
