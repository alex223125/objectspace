import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "counter", "previous", "next", "status"]

  connect() {
    this.index = Math.max(0, this.stepTargets.findIndex(step => !step.hidden))
    this.showStep()
  }

  next() {
    if (this.index < this.stepTargets.length - 1) {
      this.index++
      this.showStep()
    } else {
      this.finish()
    }
  }

  previous() {
    if (this.index > 0) {
      this.index--
      this.showStep()
    }
  }

  showStep() {
    this.stepTargets.forEach((step, index) => {
      step.hidden = index !== this.index
      step.setAttribute("aria-current", index === this.index ? "step" : "false")
    })
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = this.stepTargets.length
        ? `Step ${this.index + 1} of ${this.stepTargets.length}`
        : "No tour steps available"
    }
    if (this.hasPreviousTarget) this.previousTarget.disabled = this.index <= 0
    if (this.hasNextTarget) {
      this.nextTarget.textContent = this.index >= this.stepTargets.length - 1
        ? "Finish tour"
        : "Next"
    }
    this.announce()
  }

  announce() {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `Tour step ${this.index + 1} of ${this.stepTargets.length}`
    }
  }

  finish() {
    this.element.hidden = true
    this.element.dispatchEvent(new CustomEvent("tour:finished", { bubbles: true }))
  }

  skip() {
    this.finish()
  }
}
