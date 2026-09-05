import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search",
        "filter",
        "field",
        "count"
    ]

    static values = {
        fields: Array
    }

    connect() {
        this.currentFilter = "all"
        this.currentSearch = ""

        this.expanded = new Set()

        this.applyFilters()
        this.updateVisibleCount()

        console.log(
            "entity_template_version_compare connected"
        )

        console.log("Fields:", this.fieldsValue)

        console.log(
            "comparison fields:",
            this.hasFieldTarget
                ? this.fieldTargets.length
                : 0
        )

        console.log("========== COMPARE DEBUG ==========")

        console.log("Controller:", this)
        console.log("Element:", this.element)
        console.log("Count target:", this.countTarget)
        console.log("Fields:", this.fieldsValue)

        console.log("===================================")
    }

    disconnect() {
        this.expanded.clear()
    }


    // ========================================================================
    // SEARCH
    // ========================================================================

    searchChanged(event) {
        this.currentSearch =
            String(
                event?.target?.value || ""
            )
                .trim()
                .toLowerCase()

        this.applyFilters()
    }


    // ========================================================================
    // FILTER
    // ========================================================================

    filterChanged(event) {
        const filter =
            event?.currentTarget?.dataset?.filter || "all"

        this.currentFilter = filter

        this.updateFilterButtons()

        this.applyFilters()
    }


    // ========================================================================
    // APPLY FILTERS
    // ========================================================================

    applyFilters() {
        if (!this.hasFieldTarget) {
            this.updateVisibleCount()
            return
        }

        let visibleCount = 0

        this.fieldTargets.forEach(field => {
            const matchesFilter =
                this.matchesFilter(field)

            const matchesSearch =
                this.matchesSearch(field)

            const visible =
                matchesFilter &&
                matchesSearch

            if (visible) {
                field.classList.remove("hidden")
                visibleCount += 1
            } else {
                field.classList.add("hidden")
            }
        })

        this.updateVisibleCount(visibleCount)
    }


    // ========================================================================
    // FILTER MATCH
    // ========================================================================

    matchesFilter(field) {
        if (this.currentFilter === "all") {
            return true
        }

        const changeType =
            String(
                field.dataset.changeType || ""
            )
                .trim()
                .toLowerCase()

        return (
            changeType ===
            this.currentFilter
        )
    }


    // ========================================================================
    // SEARCH MATCH
    // ========================================================================

    matchesSearch(field) {
        if (!this.currentSearch) {
            return true
        }

        const fieldName =
            String(
                field.dataset.fieldName || ""
            )
                .toLowerCase()

        const fieldText =
            String(
                field.textContent || ""
            )
                .toLowerCase()

        return (
            fieldName.includes(
                this.currentSearch
            ) ||
            fieldText.includes(
                this.currentSearch
            )
        )
    }


    // ========================================================================
    // FILTER BUTTON UI
    // ========================================================================

    updateFilterButtons() {
        if (!this.hasFilterTarget) {
            return
        }

        this.filterTargets.forEach(button => {
            const filter =
                button.dataset.filter || "all"

            const active =
                filter === this.currentFilter

            if (active) {
                this.activateFilterButton(button)
            } else {
                this.deactivateFilterButton(button)
            }
        })
    }


    activateFilterButton(button) {
        button.classList.add(
            "ring-2",
            "ring-violet-500",
            "ring-offset-1"
        )

        button.setAttribute(
            "aria-pressed",
            "true"
        )
    }


    deactivateFilterButton(button) {
        button.classList.remove(
            "ring-2",
            "ring-violet-500",
            "ring-offset-1"
        )

        button.setAttribute(
            "aria-pressed",
            "false"
        )
    }


    // ========================================================================
    // VISIBLE COUNT
    // ========================================================================

    updateVisibleCount(explicitCount = null) {
        if (!this.hasCountTarget) {
            return
        }

        const count =
            explicitCount !== null
                ? explicitCount
                : this.hasFieldTarget
                    ? this.fieldTargets.filter(
                        field =>
                            !field.classList.contains(
                                "hidden"
                            )
                    ).length
                    : 0

        this.countTarget.textContent =
            `${count} ${
                count === 1
                    ? "field"
                    : "fields"
            }`
    }


    // ========================================================================
    // TOGGLE FIELD DETAILS
    // ========================================================================

    toggle(event) {
        const button =
            event.currentTarget

        const targetId =
            button.dataset.target

        if (!targetId) {
            return
        }

        const details =
            document.getElementById(
                targetId
            )

        if (!details) {
            console.warn(
                "Comparison details element not found:",
                targetId
            )

            return
        }

        const isHidden =
            details.classList.contains(
                "hidden"
            )

        if (isHidden) {
            this.expandDetails(
                button,
                details
            )
        } else {
            this.collapseDetails(
                button,
                details
            )
        }
    }


    // ========================================================================
    // EXPAND
    // ========================================================================

    expandDetails(button, details) {
        details.classList.remove(
            "hidden"
        )

        button.setAttribute(
            "aria-expanded",
            "true"
        )

        this.setChevron(
            button,
            true
        )

        const targetId =
            details.id

        if (targetId) {
            this.expanded.add(
                targetId
            )
        }
    }


    // ========================================================================
    // COLLAPSE
    // ========================================================================

    collapseDetails(button, details) {
        details.classList.add(
            "hidden"
        )

        button.setAttribute(
            "aria-expanded",
            "false"
        )

        this.setChevron(
            button,
            false
        )

        const targetId =
            details.id

        if (targetId) {
            this.expanded.delete(
                targetId
            )
        }
    }


    // ========================================================================
    // CHEVRON
    // ========================================================================

    setChevron(button, expanded) {
        const chevron =
            button.querySelector(
                "[data-chevron]"
            )

        if (!chevron) {
            return
        }

        if (expanded) {
            chevron.classList.add(
                "rotate-180"
            )
        } else {
            chevron.classList.remove(
                "rotate-180"
            )
        }
    }


    // ========================================================================
    // EXPAND ALL
    // ========================================================================

    expandAll() {
        if (!this.hasFieldTarget) {
            return
        }

        this.fieldTargets.forEach(field => {
            if (
                field.classList.contains(
                    "hidden"
                )
            ) {
                return
            }

            const details =
                field.querySelector(
                    "[data-compare-details]"
                )

            if (!details) {
                return
            }

            const button =
                field.querySelector(
                    'button[data-target]'
                )

            if (!button) {
                return
            }

            this.expandDetails(
                button,
                details
            )
        })
    }


    // ========================================================================
    // COLLAPSE ALL
    // ========================================================================

    collapseAll() {
        if (!this.hasFieldTarget) {
            return
        }

        this.fieldTargets.forEach(field => {
            const details =
                field.querySelector(
                    "[data-compare-details]"
                )

            if (!details) {
                return
            }

            const button =
                field.querySelector(
                    'button[data-target]'
                )

            if (!button) {
                return
            }

            this.collapseDetails(
                button,
                details
            )
        })
    }


    // ========================================================================
    // PUBLIC HELPERS
    // ========================================================================

    showAll() {
        this.currentFilter = "all"
        this.currentSearch = ""

        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        this.updateFilterButtons()
        this.applyFilters()
    }


    filterAdded() {
        this.setFilter("added")
    }


    filterRemoved() {
        this.setFilter("removed")
    }


    filterChangedFields() {
        this.setFilter("changed")
    }


    filterUnchanged() {
        this.setFilter("unchanged")
    }


    setFilter(filter) {
        this.currentFilter =
            filter || "all"

        this.updateFilterButtons()
        this.applyFilters()
    }
}
