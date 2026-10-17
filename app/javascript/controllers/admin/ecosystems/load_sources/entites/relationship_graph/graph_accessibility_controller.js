
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["instructions", "status", "svg"]

  connect() {
    this.element.classList.add("graph-accessibility-enabled")

    this.handleSelection = (event) => {
      const entity = event.detail?.entity
      if (!entity) return

      this.announce(
          `Selected ${entity.name || `entity ${entity.id}`}.`
      )
    }

    this.element.addEventListener(
        "relationship-graph:entity-selected",
        this.handleSelection
    )

    this.decorateGraph()
  }

  disconnect() {
    this.element.removeEventListener(
        "relationship-graph:entity-selected",
        this.handleSelection
    )

    this.element.classList.remove("graph-accessibility-enabled")
  }

  decorateGraph() {
    const root = this.hasSvgTarget
        ? this.svgTarget
        : this.element.querySelector("svg")

    if (!root) return

    root.setAttribute("role", "group")

    if (!root.hasAttribute("aria-label")) {
      root.setAttribute(
          "aria-label",
          "Relationship graph. Use Tab to reach entities and Enter or Space to select one."
      )
    }

    root.querySelectorAll("[data-node-id], [role='button']").forEach((node) => {
      if (!node.hasAttribute("tabindex")) {
        node.setAttribute("tabindex", "0")
      }

      if (!node.hasAttribute("aria-label")) {
        const title = node.querySelector("title")?.textContent?.trim()
        const text = node.querySelector("text")?.textContent?.trim()

        node.setAttribute(
            "aria-label",
            title || text || "Graph entity"
        )
      }
    })
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }

  showInstructions() {
    if (!this.hasInstructionsTarget) return

    this.instructionsTarget.hidden = false
    this.instructionsTarget.focus()
  }

  hideInstructions() {
    if (this.hasInstructionsTarget) {
      this.instructionsTarget.hidden = true
    }
  }

  toggleInstructions() {
    if (!this.hasInstructionsTarget) return

    if (this.instructionsTarget.hidden) {
      this.showInstructions()
    } else {
      this.hideInstructions()
    }
  }
}