import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "leftVersion",
        "rightVersion",
        "search",
        "results",
        "empty"
    ]

    connect() {
        this.filterMode = "all"
        this.applyFilters()
    }

    // ============================================================
    // FILTER
    // ============================================================

    setFilter(event) {
        this.filterMode =
            event.currentTarget.dataset.filter || "all"

        this.updateFilterButtons()
        this.applyFilters()
    }

    filter() {
        this.applyFilters()
    }

    applyFilters() {
        if (!this.hasResultsTarget) {
            return
        }

        const nodes =
            Array.from(
                this.resultsTarget.querySelectorAll("[data-diff-node]")
            )

        const query =
            this.hasSearchTarget
                ? this.searchTarget.value.trim().toLowerCase()
                : ""

        let visibleCount = 0

        nodes.forEach((node) => {
            const status =
                node.dataset.status || "unchanged"

            const searchableText =
                node.dataset.searchText || ""

            const statusMatches =
                this.filterMode === "all" ||
                status === this.filterMode

            const searchMatches =
                query === "" ||
                searchableText.includes(query)

            const visible =
                statusMatches && searchMatches

            node.classList.toggle(
                "hidden",
                !visible
            )

            if (visible) {
                visibleCount += 1
            }
        })

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.toggle(
                "hidden",
                visibleCount > 0
            )
        }
    }

    // ============================================================
    // FILTER BUTTONS
    // ============================================================

    updateFilterButtons() {
        this.element
            .querySelectorAll("[data-filter]")
            .forEach((button) => {
                const active =
                    button.dataset.filter === this.filterMode

                button.classList.toggle(
                    "ring-2",
                    active
                )

                button.classList.toggle(
                    "ring-violet-200",
                    active
                )
            })
    }

    // ============================================================
    // VERSION SELECTION
    // ============================================================

    compareVersions() {
        const left =
            this.hasLeftVersionTarget
                ? this.leftVersionTarget.value
                : null

        const right =
            this.hasRightVersionTarget
                ? this.rightVersionTarget.value
                : null

        if (!left || !right) {
            return
        }

        if (left === right) {
            return
        }
    }

    // ============================================================
    // NODE DETAILS
    // ============================================================

    toggleNode(event) {
        const button =
            event.currentTarget

        const node =
            button.closest("[data-diff-node]")

        if (!node) {
            return
        }

        const details =
            node.querySelector(
                "[data-diff-details]"
            )

        if (!details) {
            return
        }

        const hidden =
            details.classList.contains("hidden")

        details.classList.toggle(
            "hidden",
            !hidden
        )

        button.textContent =
            hidden
                ? "Hide details"
                : "Details"
    }

    // ============================================================
    // EXPAND ALL
    // ============================================================

    expandAll() {
        if (!this.hasResultsTarget) {
            return
        }

        this.resultsTarget
            .querySelectorAll(
                "[data-diff-details]"
            )
            .forEach((element) => {
                element.classList.remove("hidden")
            })

        this.resultsTarget
            .querySelectorAll(
                "[data-diff-node] button"
            )
            .forEach((button) => {
                if (
                    button.textContent.trim() === "Details"
                ) {
                    button.textContent =
                        "Hide details"
                }
            })
    }
}