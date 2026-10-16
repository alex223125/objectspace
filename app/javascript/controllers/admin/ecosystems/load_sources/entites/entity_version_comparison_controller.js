import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "row",
        "search",
        "typeFilter",
        "count",
        "empty",
        "resultsLabel",
        "progress",
        "progressLabel",
        "xp",
        "status",
        "clearSearch",
        "filterChip",
        "commandHint"
    ]

    connect() {
        this.activeFilter = "all"
        this.applyFilters()
        this.bindKeyboardShortcuts()
    }

    disconnect() {
        this.unbindKeyboardShortcuts()
    }

    // ============================================================
    // SEARCH
    // ============================================================

    searchChanged() {
        this.applyFilters()
    }

    focusSearch() {
        if (!this.hasSearchTarget) {
            return
        }

        this.searchTarget.focus()
        this.searchTarget.select()
    }

    clearSearch() {
        if (!this.hasSearchTarget) {
            return
        }

        this.searchTarget.value = ""
        this.applyFilters()
        this.searchTarget.focus()
    }

    // ============================================================
    // FILTER
    // ============================================================

    typeFilterChanged() {
        this.activeFilter =
            this.hasTypeFilterTarget
                ? this.typeFilterTarget.value
                : "all"

        this.applyFilters()
    }

    selectFilter(event) {
        const filter =
            event.currentTarget.dataset.filter || "all"

        this.activeFilter = filter

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value = filter
        }

        this.applyFilters()
    }

    // ============================================================
    // MAIN FILTER ENGINE
    // ============================================================

    applyFilters() {
        const query =
            this.hasSearchTarget
                ? this.searchTarget.value.trim().toLowerCase()
                : ""

        const filter =
            this.hasTypeFilterTarget
                ? this.typeFilterTarget.value || "all"
                : this.activeFilter

        this.activeFilter = filter

        let visible = 0

        this.rowTargets.forEach((row) => {
            const searchableText =
                [
                    row.dataset.comparisonPath,
                    row.dataset.comparisonIdentity,
                    row.dataset.oldValue,
                    row.dataset.newValue,
                    row.textContent
                ]
                    .filter(
                        (value) =>
                            value !== undefined &&
                            value !== null
                    )
                    .join(" ")
                    .toLowerCase()

            const rowType =
                row.dataset.changeType || ""

            const matchesSearch =
                !query ||
                searchableText.includes(query)

            const matchesFilter =
                filter === "all" ||
                rowType === filter

            const isVisible =
                matchesSearch &&
                matchesFilter

            row.hidden = !isVisible

            row.setAttribute(
                "aria-hidden",
                String(!isVisible)
            )

            if (isVisible) {
                visible += 1
            }
        })

        this.updateCount(visible)
        this.updateEmptyState(visible)
        this.updateProgress(visible)
        this.updateFilterChips(filter)
        this.updateSearchState(query)
    }

    // ============================================================
    // COUNT / PROGRESS
    // ============================================================

    updateCount(visible) {
        if (this.hasCountTarget) {
            this.countTarget.textContent =
                String(visible)
        }

        if (this.hasResultsLabelTarget) {
            this.resultsLabelTarget.textContent =
                `${visible} ${visible === 1 ? "result" : "results"}`
        }

        if (this.hasXpTarget) {
            const xp =
                Math.min(
                    visible * 10,
                    500
                )

            this.xpTarget.textContent =
                `+${xp} XP`
        }
    }

    updateProgress(visible) {
        const total =
            this.rowTargets.length

        const percentage =
            total === 0
                ? 0
                : Math.round(
                    (visible / total) * 100
                )

        if (this.hasProgressTarget) {
            this.progressTarget.style.width =
                `${percentage}%`
        }

        if (this.hasProgressLabelTarget) {
            this.progressLabelTarget.textContent =
                `${percentage}% visible`
        }

        if (this.hasStatusTarget) {
            if (total === 0) {
                this.statusTarget.textContent =
                    "No changes detected"
            } else if (visible === 0) {
                this.statusTarget.textContent =
                    "No matching changes"
            } else if (visible === total) {
                this.statusTarget.textContent =
                    "Full comparison explored"
            } else {
                this.statusTarget.textContent =
                    "Comparison exploration active"
            }
        }
    }

    // ============================================================
    // EMPTY STATE
    // ============================================================

    updateEmptyState(visible) {
        if (!this.hasEmptyTarget) {
            return
        }

        this.emptyTarget.hidden =
            visible !== 0
    }

    // ============================================================
    // FILTER CHIPS
    // ============================================================

    updateFilterChips(activeFilter) {
        if (!this.hasFilterChipTarget) {
            return
        }

        this.filterChipTargets.forEach((chip) => {
            const active =
                chip.dataset.filter === activeFilter

            chip.classList.toggle(
                "bg-slate-900",
                active
            )

            chip.classList.toggle(
                "text-white",
                active
            )

            chip.classList.toggle(
                "shadow-md",
                active
            )

            chip.setAttribute(
                "aria-pressed",
                String(active)
            )
        })
    }

    // ============================================================
    // SEARCH STATE
    // ============================================================

    updateSearchState(query) {
        if (!this.hasClearSearchTarget) {
            return
        }

        this.clearSearchTarget.hidden =
            query.length === 0
    }

    // ============================================================
    // RESET
    // ============================================================

    reset() {
        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value =
                "all"
        }

        this.activeFilter = "all"

        this.applyFilters()
    }

    // ============================================================
    // KEYBOARD SHORTCUTS
    // ============================================================

    bindKeyboardShortcuts() {
        this.boundKeydown =
            (event) => {
                this.handleKeydown(event)
            }

        document.addEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    unbindKeyboardShortcuts() {
        if (!this.boundKeydown) {
            return
        }

        document.removeEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    handleKeydown(event) {
        const target =
            event.target

        const isTyping =
            target &&
            (
                target.tagName === "INPUT" ||
                target.tagName === "TEXTAREA" ||
                target.tagName === "SELECT" ||
                target.isContentEditable
            )

        // "/" focuses comparison search.
        if (
            event.key === "/" &&
            !isTyping
        ) {
            event.preventDefault()
            this.focusSearch()
            return
        }

        // Escape clears search.
        if (
            event.key === "Escape" &&
            this.hasSearchTarget &&
            document.activeElement === this.searchTarget
        ) {
            this.clearSearch()
            return
        }

        // R resets comparison filters.
        if (
            event.key.toLowerCase() === "r" &&
            !isTyping
        ) {
            event.preventDefault()
            this.reset()
            return
        }

        // Cmd/Ctrl + K focuses search.
        if (
            event.key.toLowerCase() === "k" &&
            (event.metaKey || event.ctrlKey)
        ) {
            event.preventDefault()
            this.focusSearch()
        }
    }
}