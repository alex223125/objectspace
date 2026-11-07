
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "count", "progress", "summary", "selectedId", "submitButton"]

    connect() {
        this.selected = null
        this.update()
    }

    select(event) {
        const item = event.currentTarget
        const id = item.dataset.reviewId

        if (!id) return

        this.selected = item

        this.itemTargets.forEach(candidate => {
            const active = candidate === item
            candidate.classList.toggle("is-selected", active)
            candidate.setAttribute("aria-pressed", String(active))
        })

        if (this.hasSelectedIdTarget) {
            this.selectedIdTarget.value = id
        }

        if (this.hasSummaryTarget) {
            this.summaryTarget.textContent =
                item.dataset.reviewSummary ||
                item.dataset.reviewTitle ||
                "Review item selected."
        }

        this.update()
    }

    update() {
        const total = this.itemTargets.length
        const completed = this.itemTargets.filter(item =>
            item.dataset.reviewStatus === "completed"
        ).length

        const percentage = total
            ? Math.round(completed / total * 100)
            : 0

        if (this.hasCountTarget) {
            this.countTarget.textContent = `${completed} of ${total} reviews completed`
        }

        if (this.hasProgressTarget) {
            this.progressTarget.max = 100
            this.progressTarget.value = percentage
            this.progressTarget.setAttribute(
                "aria-label",
                `Review completion: ${percentage}%`
            )
        }

        if (this.hasSubmitButtonTarget) {
            this.submitButtonTarget.disabled = !this.selected
        }
    }

    confirmSubmit(event) {
        if (!this.selected) {
            event.preventDefault()

            if (this.hasSummaryTarget) {
                this.summaryTarget.textContent =
                    "Select a review item before submitting your decision."
            }
        }
    }
}