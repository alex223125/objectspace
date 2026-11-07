
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "filter", "count", "emptyState", "details", "detailsTitle", "detailsBody"]

    connect() {
        this.applyFilter()
    }

    filter() {
        this.applyFilter()
    }

    applyFilter() {
        const type = this.hasFilterTarget
            ? this.filterTarget.value
            : "all"

        let visible = 0

        this.itemTargets.forEach(item => {
            const itemType = item.dataset.evidenceType || "other"
            const matches = type === "all" || type === itemType

            item.hidden = !matches
            if (matches) visible += 1
        })

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visible} evidence ${visible === 1 ? "item" : "items"}`
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visible > 0
        }
    }

    inspect(event) {
        const item = event.currentTarget
        const title = item.dataset.evidenceTitle || "Evidence details"

        if (this.hasDetailsTitleTarget) {
            this.detailsTitleTarget.textContent = title
        }

        if (this.hasDetailsBodyTarget) {
            this.detailsBodyTarget.replaceChildren()

            const fields = [
                ["Source", item.dataset.evidenceSource],
                ["Author", item.dataset.evidenceAuthor],
                ["Published", item.dataset.evidencePublished],
                ["Retrieved", item.dataset.evidenceRetrieved],
                ["Reliability", item.dataset.evidenceReliability],
                ["Coverage", item.dataset.evidenceCoverage],
                ["Citation", item.dataset.evidenceCitation]
            ]

            fields.forEach(([label, value]) => {
                if (!value) return

                const row = document.createElement("p")
                row.className = "mt-2 text-base leading-7"

                const strong = document.createElement("strong")
                strong.textContent = `${label}: `

                const text = document.createElement("span")
                text.textContent = value

                row.append(strong, text)
                this.detailsBodyTarget.append(row)
            })

            if (!this.detailsBodyTarget.childElementCount) {
                this.detailsBodyTarget.textContent =
                    "No additional evidence metadata is available."
            }
        }

        if (this.hasDetailsTarget) {
            this.detailsTarget.hidden = false
        }
    }

    close(event) {
        event?.preventDefault()

        if (this.hasDetailsTarget) {
            this.detailsTarget.hidden = true
        }
    }
}