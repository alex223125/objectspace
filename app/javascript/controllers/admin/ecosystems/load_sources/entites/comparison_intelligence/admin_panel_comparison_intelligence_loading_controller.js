import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator", "content", "status"]

  start() {
    if (this.hasIndicatorTarget) this.indicatorTarget.hidden = false
    if (this.hasContentTarget) this.contentTarget.setAttribute("aria-busy", "true")
    if (this.hasStatusTarget) this.statusTarget.textContent = "Loading. Please wait."
    this.element.setAttribute("aria-busy", "true")
  }

  finish() {
    if (this.hasIndicatorTarget) this.indicatorTarget.hidden = true
    if (this.hasContentTarget) this.contentTarget.setAttribute("aria-busy", "false")
    if (this.hasStatusTarget) this.statusTarget.textContent = "Loading complete."
    this.element.setAttribute("aria-busy", "false")
  }

  fail() {
    if (this.hasIndicatorTarget) this.indicatorTarget.hidden = true
    if (this.hasContentTarget) this.contentTarget.setAttribute("aria-busy", "false")
    if (this.hasStatusTarget) this.statusTarget.textContent = "Loading failed. Please try again."
    this.element.setAttribute("aria-busy", "false")
  }
}
