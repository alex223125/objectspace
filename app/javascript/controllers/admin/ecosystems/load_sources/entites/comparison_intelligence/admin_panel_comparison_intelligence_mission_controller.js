import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "progress", "status"]

  toggle(event) {
    const button = event.currentTarget
    const completed = button.getAttribute("aria-pressed") !== "true"
    button.setAttribute("aria-pressed", String(completed))
    button.classList.toggle("is-completed", completed)

    const item = button.closest("[data-mission-item]")
    item?.classList.toggle("is-completed", completed)

    this.updateProgress()
  }

  updateProgress() {
    const buttons = this.element.querySelectorAll("[data-mission-toggle]")
    const completed = [...buttons].filter(
      button => button.getAttribute("aria-pressed") === "true"
    ).length
    const total = buttons.length
    const percent = total ? Math.round((completed / total) * 100) : 0

    if (this.hasProgressTarget) {
      this.progressTarget.textContent = `${completed} of ${total} completed`
      this.progressTarget.setAttribute("aria-valuenow", String(percent))
    }
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `Mission progress: ${percent}%`
    }
  }
}
