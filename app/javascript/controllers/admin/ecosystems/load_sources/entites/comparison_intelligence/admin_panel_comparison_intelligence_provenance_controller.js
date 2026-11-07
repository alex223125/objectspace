
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["event", "filter", "count", "detail", "detailTitle", "detailBody"]

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

        this.eventTargets.forEach(item => {
            const eventType = item.dataset.provenanceType || "other"
            const matches = type === "all" || type === eventType

            item.hidden = !matches
            if (matches) visible += 1
        })

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visible} provenance ${visible === 1 ? "event" : "events"}`
        }
    }

    inspect(event) {
        const item = event.currentTarget

        if (this.hasDetailTitleTarget) {
            this.detailTitleTarget.textContent =
                item.dataset.provenanceTitle || "Provenance event"
        }

        if (this.hasDetailBodyTarget) {
            this.detailBodyTarget.replaceChildren()

            const fields = [
                ["Event", item.dataset.provenanceType],
                ["Entity", item.dataset.entityName],
                ["Entity ID", item.dataset.entityId],
                ["Actor", item.dataset.provenanceActor],
                ["Date", item.dataset.provenanceDate],
                ["Source", item.dataset.provenanceSource],
                ["Operation", item.dataset.provenanceOperation],
                ["Record ID", item.dataset.provenanceRecordId]
            ]

            fields.forEach(([label, value]) => {
                if (!value) return

                const p = document.createElement("p")
                p.className = "mt-2 text-base leading-7"

                const strong = document.createElement("strong")
                strong.textContent = `${label}: `

                const span = document.createElement("span")
                span.textContent = value

                p.append(strong, span)
                this.detailBodyTarget.append(p)
            })

            if (!this.detailBodyTarget.childElementCount) {
                this.detailBodyTarget.textContent =
                    "No additional provenance details are available."
            }
        }

        if (this.hasDetailTarget) {
            this.detailTarget.hidden = false
        }
    }

    close(event) {
        event?.preventDefault()

        if (this.hasDetailTarget) {
            this.detailTarget.hidden = true
        }
    }
}