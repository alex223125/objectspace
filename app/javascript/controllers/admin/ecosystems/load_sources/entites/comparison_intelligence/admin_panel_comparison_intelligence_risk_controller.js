
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "filter", "summary", "detail", "detailTitle", "detailBody"]

    connect() {
        this.applyFilter()
    }

    filter() {
        this.applyFilter()
    }

    applyFilter() {
        const severity = this.hasFilterTarget
            ? this.filterTarget.value
            : "all"

        let visible = 0

        this.itemTargets.forEach(item => {
            const level = (item.dataset.riskLevel || "unknown").toLowerCase()
            const matches = severity === "all" || level === severity

            item.hidden = !matches
            if (matches) visible += 1
        })

        if (this.hasSummaryTarget) {
            this.summaryTarget.textContent =
                `${visible} risk ${visible === 1 ? "item" : "items"} shown`
        }
    }

    inspect(event) {
        const item = event.currentTarget
        const level = item.dataset.riskLevel || "unknown"
        const title = item.dataset.riskTitle || "Risk assessment"
        const explanation = item.dataset.riskExplanation ||
            "No explanation was supplied for this assessment."
        const factors = item.dataset.riskFactors ||
            "No contributing factors were supplied."

        if (this.hasDetailTitleTarget) {
            this.detailTitleTarget.textContent =
                `${title} — ${level.toUpperCase()}`
        }

        if (this.hasDetailBodyTarget) {
            this.detailBodyTarget.replaceChildren()

            for (const [heading, content] of [
                ["Explanation", explanation],
                ["Contributing factors", factors],
                ["Recommended action", item.dataset.riskAction ||
                "Review the underlying evidence before making a decision."]
            ]) {
                const section = document.createElement("section")
                section.className = "mt-4"

                const h = document.createElement("h4")
                h.className = "text-lg font-bold"
                h.textContent = heading

                const p = document.createElement("p")
                p.className = "mt-1 text-base leading-7"
                p.textContent = content

                section.append(h, p)
                this.detailBodyTarget.append(section)
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