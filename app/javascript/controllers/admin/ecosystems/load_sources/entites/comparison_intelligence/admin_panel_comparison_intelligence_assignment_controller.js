import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["assignee", "status", "form"]

  assigneeChanged() {
    if (!this.hasAssigneeTarget || !this.hasStatusTarget) return
    const selected = this.assigneeTarget.selectedOptions?.[0]
    this.statusTarget.textContent = selected?.textContent?.trim()
      ? `Selected: ${selected.textContent.trim()}. Save to apply the assignment.`
      : "Choose a reviewer."
  }

  submit(event) {
    if (this.hasFormTarget && !this.formTarget.checkValidity()) {
      event?.preventDefault()
      this.formTarget.reportValidity()
      return
    }
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = "Saving assignment…"
      this.statusTarget.setAttribute("role", "status")
    }
  }
}
