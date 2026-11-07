
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["row", "count", "emptyState", "search"]
    static values = {
        filter: { type: String, default: "all" }
    }

    connect() {
        this.refresh()
    }

    filter(event) {
        this.filterValue = event.currentTarget.value || "all"
        this.refresh()
    }

    search() {
        this.refresh()
    }

    refresh() {
        const query = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : ""

        let visible = 0

        this.rowTargets.forEach(row => {
            const type = (row.dataset.changeType || "changed").toLowerCase()
            const searchableText = [
                row.textContent,
                row.dataset.changePath,
                row.dataset.changeDescription
            ].filter(Boolean).join(" ").toLowerCase()

            const matchesFilter =
                this.filterValue === "all" || type === this.filterValue

            const matchesSearch = !query || searchableText.includes(query)
            const show = matchesFilter && matchesSearch

            row.hidden = !show
            if (show) visible += 1
        })

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visible} ${visible === 1 ? "change" : "changes"} shown`
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visible !== 0
        }
    }

    clearFilters(event) {
        event?.preventDefault()
        this.filterValue = "all"

        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        this.element.querySelectorAll("[data-change-filter]").forEach(input => {
            if ("value" in input) input.value = "all"
        })

        this.refresh()
    }
}