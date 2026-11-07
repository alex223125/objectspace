
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["card", "detail", "detailTitle", "detailBody", "status"]

    connect() {
        this.updateStatus()
    }

    inspect(event) {
        const card = event.currentTarget
        const title = card.dataset.metricTitle || "Metric details"
        const description =
            card.dataset.metricDescription || "No explanation is available."
        const value = card.dataset.metricValue || "Not calculated"
        const guidance =
            card.dataset.metricGuidance || "Review the underlying changes for context."

        if (this.hasDetailTitleTarget) {
            this.detailTitleTarget.textContent = title
        }

        if (this.hasDetailBodyTarget) {
            this.detailBodyTarget.replaceChildren()

            const valueElement = document.createElement("p")
            valueElement.className = "text-2xl font-bold"
            valueElement.textContent = value

            const descriptionElement = document.createElement("p")
            descriptionElement.className = "mt-3 text-base leading-7"
            descriptionElement.textContent = description

            const guidanceElement = document.createElement("p")
            guidanceElement.className = "mt-3 text-base leading-7"
            guidanceElement.textContent = `Admin guidance: ${guidance}`

            this.detailBodyTarget.append(
                valueElement,
                descriptionElement,
                guidanceElement
            )
        }

        if (this.hasDetailTarget) {
            this.detailTarget.hidden = false
        }

        this.cardTargets.forEach(item => {
            item.setAttribute("aria-pressed", String(item === card))
        })

        this.updateStatus(`Showing details for ${title}.`)
    }

    close(event) {
        event?.preventDefault()

        if (this.hasDetailTarget) {
            this.detailTarget.hidden = true
        }

        this.cardTargets.forEach(item => {
            item.setAttribute("aria-pressed", "false")
        })

        this.updateStatus("Metric details closed.")
    }

    updateStatus(message = "") {
        if (!this.hasStatusTarget) return

        this.statusTarget.textContent = message ||
            `${this.cardTargets.length} metrics available. Select a metric to learn more.`
    }
}