
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "status", "help"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    this.element.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.onKeydown)
  }

  onKeydown(event) {
    if (event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey) {
      return
    }

    const target = event.target
    const tag = target?.tagName?.toLowerCase()

    if (
        target?.isContentEditable ||
        ["input", "textarea", "select"].includes(tag)
    ) {
      if (event.key === "Escape" && tag === "input") {
        target.value = ""
        target.dispatchEvent(new Event("input", { bubbles: true }))
      }

      return
    }

    switch (event.key.toLowerCase()) {
      case "/":
        event.preventDefault()
        this.focusSearch()
        break

      case "f":
        event.preventDefault()
        this.dispatchAction("graph-canvas#fit")
        this.dispatchAction("graph-layout#fit")
        this.announce("Fit command requested.")
        break

      case "r":
        event.preventDefault()
        this.dispatchAction("graph-canvas#reset")
        this.dispatchAction("graph-layout#reset")
        this.announce("Reset command requested.")
        break

      case "?":
        event.preventDefault()
        this.toggleHelp()
        break

      case "escape":
        this.dispatchAction("graph-canvas#reset")
        this.announce("Selection cleared.")
        break
    }
  }

  focusSearch() {
    const search = this.hasSearchTarget
        ? this.searchTarget
        : this.element.querySelector(
            "[data-graph-canvas-target='search'], " +
            "[data-graph-search-target='input'], " +
            "input[type='search']"
        )

    if (!search) {
      this.announce("Search field is unavailable.")
      return
    }

    search.focus()
    search.select?.()
  }

  dispatchAction(action) {
    const button = this.element.querySelector(
        `[data-action~="${action}"]`
    )

    if (button && !button.disabled) {
      button.click()
      return
    }

    const [controller, method] = action.split("#")

    this.element.dispatchEvent(
        new CustomEvent("relationship-graph:command", {
          bubbles: true,
          detail: { controller, method }
        })
    )
  }

  toggleHelp() {
    if (this.hasHelpTarget) {
      this.helpTarget.hidden = !this.helpTarget.hidden
      if (!this.helpTarget.hidden) this.helpTarget.focus()
      return
    }

    this.announce(
        "Shortcuts: slash to search, F to fit, R to reset, Escape to clear selection, question mark for help."
    )
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      return
    }

    const status = this.element.querySelector(
        "[aria-live='polite']"
    )

    if (status) status.textContent = message
  }
}