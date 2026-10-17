
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "status", "button"]

  connect() {
    this.originalTitle = document.title
    this.onFullscreenChange = this.onFullscreenChange.bind(this)

    document.addEventListener(
        "fullscreenchange",
        this.onFullscreenChange
    )

    this.updateButton()
  }

  disconnect() {
    document.removeEventListener(
        "fullscreenchange",
        this.onFullscreenChange
    )

    document.title = this.originalTitle
  }

  async toggle() {
    if (document.fullscreenElement) {
      await this.exitFullscreen()
      return
    }

    await this.enterFullscreen()
  }

  async enterFullscreen() {
    const element = this.hasContentTarget
        ? this.contentTarget
        : this.element

    try {
      if (element.requestFullscreen) {
        await element.requestFullscreen()
        this.announce("Presentation mode enabled.")
      } else {
        this.element.classList.add("graph-presentation-mode")
        this.announce("Presentation styling enabled.")
      }
    } catch (_error) {
      this.element.classList.add("graph-presentation-mode")
      this.announce(
          "Fullscreen is unavailable. Presentation styling enabled instead."
      )
    }

    this.updateButton()
  }

  async exitFullscreen() {
    try {
      if (document.fullscreenElement) {
        await document.exitFullscreen()
      }
    } catch (_error) {
      // The browser may already have exited fullscreen.
    }

    this.element.classList.remove("graph-presentation-mode")
    this.announce("Presentation mode disabled.")
    this.updateButton()
  }

  toggleStyling() {
    const enabled = this.element.classList.toggle(
        "graph-presentation-mode"
    )

    this.announce(
        enabled
            ? "Presentation styling enabled."
            : "Presentation styling disabled."
    )

    this.updateButton()
  }

  onFullscreenChange() {
    this.updateButton()

    if (!document.fullscreenElement) {
      this.element.classList.remove("graph-presentation-mode")
    }
  }

  updateButton() {
    if (!this.hasButtonTarget) return

    const active = Boolean(document.fullscreenElement) ||
        this.element.classList.contains("graph-presentation-mode")

    this.buttonTarget.textContent = active
        ? "Exit presentation"
        : "Presentation mode"

    this.buttonTarget.setAttribute(
        "aria-pressed",
        String(active)
    )
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}