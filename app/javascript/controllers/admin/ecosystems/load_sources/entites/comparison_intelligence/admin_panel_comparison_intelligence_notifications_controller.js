import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notification", "status", "count"]

  dismiss(event) {
    const notification = event.currentTarget.closest("[data-notification]")
      || event.currentTarget.closest("article")
      || event.currentTarget.parentElement

    if (notification) notification.hidden = true
    this.updateCount()
  }

  dismissAll() {
    this.notificationTargets.forEach(item => { item.hidden = true })
    this.updateCount()
    if (this.hasStatusTarget) this.statusTarget.textContent = "All notifications dismissed."
  }

  updateCount() {
    const remaining = this.notificationTargets.filter(item => !item.hidden).length
    if (this.hasCountTarget) this.countTarget.textContent = String(remaining)
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `${remaining} notification${remaining === 1 ? "" : "s"} remaining.`
    }
  }
}
