import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "field",
        "search",
        "filter",
        "count"
    ]

    static values = {
        fields: Array
    }

    connect() {
        this.currentFilter = "all"
        this.currentSearch = ""

        this.initializeFields()
        this.updateCount()
    }


    // ============================================================
    // INITIALIZATION
    // ============================================================

    initializeFields() {
        this.fieldTargets.forEach((field) => {
            this.setFieldVisible(field, true)
            this.closeDetails(field)
        })

        this.updateFilterButtons()
    }


    // ============================================================
    // SEARCH
    // ============================================================

    searchChanged(event) {
        this.currentSearch =
            event.target.value
                .toString()
                .trim()
                .toLowerCase()

        this.applyFilters()
    }


    // ============================================================
    // FILTER
    // ============================================================

    filterChanged(event) {
        const filter =
            event.currentTarget.dataset.filter || "all"

        this.currentFilter = filter

        this.updateFilterButtons()
        this.applyFilters()
    }


    // ============================================================
    // APPLY SEARCH + FILTER
    // ============================================================

    applyFilters() {
        let visibleCount = 0

        this.fieldTargets.forEach((field) => {
            const matchesFilter =
                this.matchesCurrentFilter(field)

            const matchesSearch =
                this.matchesCurrentSearch(field)

            const visible =
                matchesFilter && matchesSearch

            this.setFieldVisible(field, visible)

            if (visible) {
                visibleCount += 1
            }
        })

        this.updateCount(visibleCount)
    }


    // ============================================================
    // FILTER MATCH
    // ============================================================

    matchesCurrentFilter(field) {
        if (this.currentFilter === "all") {
            return true
        }

        const changeType =
            this.normalizedChangeType(field)

        return changeType === this.currentFilter
    }


    // ============================================================
    // SEARCH MATCH
    // ============================================================

    matchesCurrentSearch(field) {
        if (!this.currentSearch) {
            return true
        }

        const searchText =
            this.searchTextFor(field)

        return searchText.includes(
            this.currentSearch
        )
    }


    // ============================================================
    // BUILD SEARCH TEXT
    // ============================================================

    searchTextFor(field) {
        const parts = []

        // ----------------------------------------------------------
        // HTML DATA
        // ----------------------------------------------------------

        const fieldName =
            field.dataset.fieldName

        if (fieldName) {
            parts.push(fieldName)
        }


        // ----------------------------------------------------------
        // FIELD DATA FROM STIMULUS VALUE
        // ----------------------------------------------------------

        const index =
            this.fieldTargets.indexOf(field)

        if (
            index >= 0 &&
            this.hasFieldsValue &&
            Array.isArray(this.fieldsValue)
        ) {
            const fieldData =
                this.fieldsValue[index]

            if (fieldData) {
                parts.push(
                    this.stringifyForSearch(fieldData)
                )
            }
        }


        // ----------------------------------------------------------
        // VISIBLE TEXT
        // ----------------------------------------------------------

        parts.push(
            field.textContent || ""
        )

        return parts
            .join(" ")
            .toLowerCase()
    }


    // ============================================================
    // STRINGIFY OBJECT FOR SEARCH
    // ============================================================

    stringifyForSearch(value) {
        try {
            return JSON.stringify(value)
        } catch (error) {
            return String(value)
        }
    }


    // ============================================================
    // NORMALIZE CHANGE TYPE
    // ============================================================

    normalizedChangeType(field) {
        const value =
            (
                field.dataset.changeType ||
                ""
            )
                .toString()
                .trim()
                .toLowerCase()

        switch (value) {
            case "add":
            case "added":
                return "added"

            case "remove":
            case "removed":
            case "deleted":
                return "removed"

            case "modify":
            case "modified":
            case "change":
            case "changed":
                return "changed"

            case "unchanged":
            default:
                return "unchanged"
        }
    }


    // ============================================================
    // VISIBILITY
    // ============================================================

    setFieldVisible(field, visible) {
        if (visible) {
            field.classList.remove("hidden")
        } else {
            field.classList.add("hidden")
        }
    }


    // ============================================================
    // UPDATE COUNT
    // ============================================================

    updateCount(count = null) {
        if (!this.hasCountTarget) {
            return
        }

        const value =
            count === null
                ? this.visibleFieldCount()
                : count

        this.countTarget.textContent =
            `${value} ${value === 1 ? "field" : "fields"}`
    }


    // ============================================================
    // VISIBLE FIELD COUNT
    // ============================================================

    visibleFieldCount() {
        return this.fieldTargets.filter(
            (field) =>
                !field.classList.contains("hidden")
        ).length
    }


    // ============================================================
    // UPDATE FILTER BUTTONS
    // ============================================================

    updateFilterButtons() {
        this.filterTargets.forEach((button) => {
            const filter =
                button.dataset.filter || "all"

            const active =
                filter === this.currentFilter

            button.setAttribute(
                "aria-pressed",
                active.toString()
            )

            if (active) {
                this.activateFilterButton(button)
            } else {
                this.deactivateFilterButton(button)
            }
        })
    }


    // ============================================================
    // ACTIVE FILTER BUTTON
    // ============================================================

    activateFilterButton(button) {
        button.classList.add(
            "ring-2",
            "ring-violet-500",
            "ring-offset-1"
        )

        button.classList.remove(
            "opacity-60"
        )
    }


    // ============================================================
    // INACTIVE FILTER BUTTON
    // ============================================================

    deactivateFilterButton(button) {
        button.classList.remove(
            "ring-2",
            "ring-violet-500",
            "ring-offset-1"
        )
    }


    // ============================================================
    // TOGGLE DETAILS
    // ============================================================

    toggle(event) {
        event.preventDefault()

        const button =
            event.currentTarget

        const targetId =
            button.dataset.target

        if (!targetId) {
            return
        }

        const details =
            document.getElementById(targetId)

        if (!details) {
            return
        }

        const isOpen =
            !details.classList.contains("hidden")

        if (isOpen) {
            this.closeDetailsElement(
                details,
                button
            )
        } else {
            this.openDetailsElement(
                details,
                button
            )
        }
    }


    // ============================================================
    // OPEN DETAILS
    // ============================================================

    openDetailsElement(details, button) {
        details.classList.remove("hidden")

        button.setAttribute(
            "aria-expanded",
            "true"
        )

        this.setChevron(
            button,
            true
        )
    }


    // ============================================================
    // CLOSE DETAILS
    // ============================================================

    closeDetailsElement(details, button) {
        details.classList.add("hidden")

        button.setAttribute(
            "aria-expanded",
            "false"
        )

        this.setChevron(
            button,
            false
        )
    }


    // ============================================================
    // CLOSE DETAILS FOR FIELD
    // ============================================================

    closeDetails(field) {
        const details =
            field.querySelector(
                "[data-compare-details]"
            )

        if (!details) {
            return
        }

        details.classList.add("hidden")

        const button =
            field.querySelector(
                'button[data-target]'
            )

        if (button) {
            button.setAttribute(
                "aria-expanded",
                "false"
            )

            this.setChevron(
                button,
                false
            )
        }
    }


    // ============================================================
    // OPEN DETAILS FOR FIELD
    // ============================================================

    openDetails(field) {
        const details =
            field.querySelector(
                "[data-compare-details]"
            )

        if (!details) {
            return
        }

        details.classList.remove("hidden")

        const button =
            field.querySelector(
                'button[data-target]'
            )

        if (button) {
            button.setAttribute(
                "aria-expanded",
                "true"
            )

            this.setChevron(
                button,
                true
            )
        }
    }


    // ============================================================
    // CHEVRON
    // ============================================================

    setChevron(button, open) {
        const chevron =
            button.querySelector(
                "[data-chevron]"
            )

        if (!chevron) {
            return
        }

        if (open) {
            chevron.classList.add(
                "rotate-180"
            )
        } else {
            chevron.classList.remove(
                "rotate-180"
            )
        }
    }


    // ============================================================
    // EXPAND ALL
    // ============================================================

    expandAll(event) {
        if (event) {
            event.preventDefault()
        }

        this.fieldTargets.forEach((field) => {
            if (
                !field.classList.contains("hidden")
            ) {
                this.openDetails(field)
            }
        })
    }


    // ============================================================
    // COLLAPSE ALL
    // ============================================================

    collapseAll(event) {
        if (event) {
            event.preventDefault()
        }

        this.fieldTargets.forEach((field) => {
            this.closeDetails(field)
        })
    }


    // ============================================================
    // ESCAPE KEY SUPPORT
    // ============================================================

    keydown(event) {
        if (event.key === "Escape") {
            this.collapseAll()
        }
    }


    // ============================================================
    // DISCONNECT
    // ============================================================

    disconnect() {
        this.currentFilter = "all"
        this.currentSearch = ""
    }
}
