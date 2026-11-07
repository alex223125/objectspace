
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "count", "progress", "submitButton", "status"]
    static values = {
        requireAll: { type: Boolean, default: true }
    }

    connect() {
        this.update()
    }

    change() {
        this.update()
    }

    update() {
        const items = this.itemTargets
        const completed = items.filter(item => item.checked).length
        const total = items.length
        const percentage = total
            ? Math.round(completed / total * 100)
            : 0

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${completed} of ${total} review requirements completed`
        }

        if (this.hasProgressTarget) {
            this.progressTarget.max = 100
            this.progressTarget.value = percentage
            this.progressTarget.setAttribute(
                "aria-label",
                `Review checklist completion: ${percentage}%`
            )
        }

        const canSubmit = !this.requireAllValue || completed === total

        if (this.hasSubmitButtonTarget) {
            this.submitButtonTarget.disabled = !canSubmit
            this.submitButtonTarget.title = canSubmit
                ? "Submit the review"
                : "Complete all required checklist items first"
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = canSubmit
                ? "Checklist requirements satisfied."
                : `Complete ${total - completed} more requirement(s) before submitting.`
        }
    }
}