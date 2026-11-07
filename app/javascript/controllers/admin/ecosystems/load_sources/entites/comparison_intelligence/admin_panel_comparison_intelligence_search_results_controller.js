
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item", "emptyState", "count", "status"]

    connect() {
        this.query = ""
        this.apply()
    }

    filter(event) {
        this.query = event.detail?.query || ""
        this.apply()
    }

    setQuery(event) {
        this.query = event.detail?.query || ""
        this.apply()
    }

    apply() {
        const query = this.query.toLocaleLowerCase()
        let visibleCount = 0

        this.itemTargets.forEach(item => {
            const searchable = [
                item.dataset.searchText,
                item.dataset.searchPath,
                item.dataset.searchType,
                item.textContent
            ].filter(Boolean).join(" ").toLocaleLowerCase()

            const visible = !query || searchable.includes(query)

            item.hidden = !visible
            item.setAttribute("aria-hidden", String(!visible))

            if (visible) visibleCount += 1
        })

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visibleCount > 0
        }

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visibleCount} ${visibleCount === 1 ? "result" : "results"}`
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = query
                ? `${visibleCount} matching results`
                : `${visibleCount} results available`
        }

        this.dispatch("updated", {
            detail: {
                query: this.query,
                visibleCount,
                totalCount: this.itemTargets.length
            }
        })
    }

    reset() {
        this.query = ""
        this.apply()
    }
}