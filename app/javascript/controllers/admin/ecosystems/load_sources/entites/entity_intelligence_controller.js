import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "relationshipRow",
        "filter",
        "emptyState",
        "discoverButton",
        "discoveryStatus"
    ]

    connect() {
        this.applyFilter()
    }

    filter() {
        this.applyFilter()
    }

    applyFilter() {
        const query =
            this.hasFilterTarget
                ? this.filterTarget.value.toLowerCase().trim()
                : ""

        let visible = 0

        this.relationshipRowTargets.forEach((row) => {
            const haystack =
                row.dataset.search.toLowerCase()

            const matches =
                query.length === 0 ||
                haystack.includes(query)

            row.classList.toggle("hidden", !matches)

            if (matches) {
                visible += 1
            }
        })

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.classList.toggle(
                "hidden",
                visible > 0
            )
        }
    }

    prepareDiscovery(event) {
        const button = event.currentTarget

        button.disabled = true

        button.dataset.originalText =
            button.innerText

        button.innerText =
            "DISCOVERING…"

        if (this.hasDiscoveryStatusTarget) {
            this.discoveryStatusTarget.classList.remove("hidden")
        }
    }

    toggleEvidence(event) {
        const targetId =
            event.currentTarget.dataset.target

        const target =
            this.element.querySelector(
                `[data-evidence="${targetId}"]`
            )

        if (!target) return

        target.classList.toggle("hidden")

        event.currentTarget.setAttribute(
            "aria-expanded",
            String(
                !target.classList.contains("hidden")
            )
        )
    }
}