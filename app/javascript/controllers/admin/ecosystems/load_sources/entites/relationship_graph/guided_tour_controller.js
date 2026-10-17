
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step",
    "counter",
    "progress",
    "previous",
    "next",
    "status",
    "panel"
  ]

  connect() {
    this.currentIndex = 0
    this.steps = this.stepTargets

    if (this.steps.length === 0) {
      this.announce("No guided tour steps are configured.")
      return
    }

    this.showStep(0)
  }

  start() {
    if (this.steps.length === 0) return

    if (this.hasPanelTarget) {
      this.panelTarget.hidden = false
    }

    this.showStep(0)
  }

  next() {
    if (this.currentIndex < this.steps.length - 1) {
      this.showStep(this.currentIndex + 1)
    } else {
      this.finish()
    }
  }

  previous() {
    if (this.currentIndex > 0) {
      this.showStep(this.currentIndex - 1)
    }
  }

  showStep(index) {
    if (index < 0 || index >= this.steps.length) return

    this.currentIndex = index

    this.steps.forEach((step, stepIndex) => {
      step.hidden = stepIndex !== index
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent =
          `Step ${index + 1} of ${this.steps.length}`
    }

    if (this.hasProgressTarget) {
      this.progressTarget.style.width =
          `${((index + 1) / this.steps.length) * 100}%`

      this.progressTarget.setAttribute(
          "aria-valuenow",
          String(index + 1)
      )
    }

    if (this.hasPreviousTarget) {
      this.previousTarget.disabled = index === 0
    }

    if (this.hasNextTarget) {
      this.nextTarget.textContent =
          index === this.steps.length - 1
              ? "Finish tour"
              : "Next step"
    }

    this.announce(
        `Showing step ${index + 1} of ${this.steps.length}.`
    )
  }

  finish() {
    if (this.hasPanelTarget) {
      this.panelTarget.hidden = true
    }

    this.announce("Guided tour completed.")
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.hidden = true
    }

    this.announce("Guided tour closed.")
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}