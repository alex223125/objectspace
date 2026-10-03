import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search",
        "typeFilter",
        "row",
        "visibleCount",
        "totalCount",
        "progress",
        "progressLabel",
        "resultSummary",
        "empty",
        "chip",
        "shareButton",
        "activity",
        "command"
    ]

    connect() {
        this.activeFilter = "all"
        this.searchTerm = ""
        this.storageKey = this.buildStorageKey()

        this.restoreState()
        this.bindKeyboardShortcuts()
        this.apply()
        this.refreshActivity()
    }

    disconnect() {
        this.unbindKeyboardShortcuts()
    }

    // ============================================================
    // SEARCH
    // ============================================================

    searchChanged() {
        this.searchTerm = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : ""

        this.persistState()
        this.apply()
    }

    // ============================================================
    // FILTER
    // ============================================================

    filterChanged(event) {
        this.activeFilter =
            event.currentTarget.dataset.filter ||
            this.hasTypeFilterTarget
                ? this.typeFilterTarget.value
                : "all"

        if (event.currentTarget.dataset.filter) {
            this.activeFilter =
                event.currentTarget.dataset.filter

            if (this.hasTypeFilterTarget) {
                this.typeFilterTarget.value =
                    this.activeFilter
            }
        }

        this.persistState()
        this.apply()
    }

    typeFilterChanged() {
        this.activeFilter =
            this.hasTypeFilterTarget
                ? this.typeFilterTarget.value
                : "all"

        this.persistState()
        this.apply()
    }

    // ============================================================
    // RESET
    // ============================================================

    reset() {
        this.searchTerm = ""
        this.activeFilter = "all"

        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value = "all"
        }

        this.persistState()
        this.apply()

        this.trackActivity("Comparison reset")
        this.focusSearch()
    }

    // ============================================================
    // FILTER ENGINE
    // ============================================================

    apply() {
        const rows = this.rowTargets

        let visible = 0

        rows.forEach((row) => {
            const matchesSearch =
                this.matchesSearch(row)

            const matchesType =
                this.matchesType(row)

            const shouldShow =
                matchesSearch &&
                matchesType

            this.setVisibility(
                row,
                shouldShow
            )

            if (shouldShow) {
                visible += 1
            }
        })

        this.updateCounts(
            visible,
            rows.length
        )

        this.updateProgress(
            visible,
            rows.length
        )

        this.updateSummary(
            visible,
            rows.length
        )

        this.updateChips()

        if (this.hasEmptyTarget) {
            this.emptyTarget.hidden =
                visible !== 0
        }

        this.animateResultChange()
    }

    matchesSearch(row) {
        if (!this.searchTerm) {
            return true
        }

        const searchable =
            [
                row.dataset.changeType,
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

        return searchable.includes(
            this.searchTerm
        )
    }

    matchesType(row) {
        if (
            !this.activeFilter ||
            this.activeFilter === "all"
        ) {
            return true
        }

        return (
            row.dataset.changeType ===
            this.activeFilter
        )
    }

    setVisibility(row, visible) {
        row.hidden = !visible

        row.classList.toggle(
            "entity-comparison-row--hidden",
            !visible
        )

        row.setAttribute(
            "aria-hidden",
            String(!visible)
        )
    }

    // ============================================================
    // COUNTS
    // ============================================================

    updateCounts(visible, total) {
        if (this.hasVisibleCountTarget) {
            this.visibleCountTarget.textContent =
                String(visible)
        }

        if (this.hasTotalCountTarget) {
            this.totalCountTarget.textContent =
                String(total)
        }
    }

    // ============================================================
    // PROGRESS / GAMIFICATION
    // ============================================================

    updateProgress(visible, total) {
        if (!this.hasProgressTarget) {
            return
        }

        if (total === 0) {
            this.progressTarget.style.width = "0%"
            return
        }

        const percentage =
            Math.round(
                (visible / total) * 100
            )

        this.progressTarget.style.width =
            `${percentage}%`

        if (this.hasProgressLabelTarget) {
            this.progressLabelTarget.textContent =
                `${percentage}% of comparison visible`
        }
    }

    // ============================================================
    // INTELLIGENCE SUMMARY
    // ============================================================

    updateSummary(visible, total) {
        if (!this.hasResultSummaryTarget) {
            return
        }

        if (total === 0) {
            this.resultSummaryTarget.textContent =
                "No comparison facts available."

            return
        }

        if (
            visible === total &&
            !this.searchTerm &&
            this.activeFilter === "all"
        ) {
            this.resultSummaryTarget.textContent =
                `Exploring all ${total} comparison facts.`
            return
        }

        this.resultSummaryTarget.textContent =
            `Showing ${visible} of ${total} comparison facts.`
    }

    // ============================================================
    // FILTER CHIPS
    // ============================================================

    updateChips() {
        if (!this.hasChipTarget) {
            return
        }

        this.chipTargets.forEach((chip) => {
            const filter =
                chip.dataset.filter || "all"

            chip.classList.toggle(
                "is-active",
                filter === this.activeFilter
            )

            chip.setAttribute(
                "aria-pressed",
                String(
                    filter === this.activeFilter
                )
            )
        })
    }

    // ============================================================
    // ACTIVITY
    // ============================================================

    refreshActivity() {
        if (!this.hasActivityTarget) {
            return
        }

        const visited =
            Number(
                window.sessionStorage.getItem(
                    this.storageKey
                ) || 0
            )

        this.activityTarget.textContent =
            visited > 0
                ? `${visited} exploration${visited === 1 ? "" : "s"}`
                : "New exploration"
    }

    trackActivity(label) {
        const current =
            Number(
                window.sessionStorage.getItem(
                    this.storageKey
                ) || 0
            )

        const next =
            current + 1

        window.sessionStorage.setItem(
            this.storageKey,
            String(next)
        )

        if (this.hasActivityTarget) {
            this.activityTarget.textContent =
                `${next} exploration${next === 1 ? "" : "s"}`
        }

        if (this.hasCommandTarget) {
            this.commandTarget.textContent =
                label
        }
    }

    // ============================================================
    // SHARE
    // ============================================================

    async share() {
        const url =
            new URL(
                window.location.href
            )

        if (this.searchTerm) {
            url.searchParams.set(
                "comparison_search",
                this.searchTerm
            )
        } else {
            url.searchParams.delete(
                "comparison_search"
            )
        }

        if (
            this.activeFilter &&
            this.activeFilter !== "all"
        ) {
            url.searchParams.set(
                "comparison_filter",
                this.activeFilter
            )
        } else {
            url.searchParams.delete(
                "comparison_filter"
            )
        }

        const shareUrl =
            url.toString()

        try {
            if (
                navigator.share
            ) {
                await navigator.share({
                    title:
                    document.title,
                    url:
                    shareUrl
                })
            } else if (
                navigator.clipboard
            ) {
                await navigator.clipboard.writeText(
                    shareUrl
                )

                this.showCommand(
                    "Comparison link copied"
                )
            }

            this.trackActivity(
                "Comparison shared"
            )
        } catch (error) {
            // User cancelled native share.
        }
    }

    // ============================================================
    // KEYBOARD SHORTCUTS
    // ============================================================

    bindKeyboardShortcuts() {
        this.boundKeydown =
            (event) => {
                this.handleKeydown(
                    event
                )
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
        const tag =
            event.target?.tagName

        const typing =
            tag === "INPUT" ||
            tag === "TEXTAREA" ||
            tag === "SELECT"

        if (
            event.key === "/" &&
            !typing
        ) {
            event.preventDefault()
            this.focusSearch()
            return
        }

        if (
            event.key === "Escape" &&
            typing
        ) {
            if (
                this.hasSearchTarget &&
                event.target ===
                this.searchTarget
            ) {
                this.reset()
            }
        }

        if (
            event.key.toLowerCase() ===
            "r" &&
            !typing
        ) {
            this.reset()
        }
    }

    focusSearch() {
        if (!this.hasSearchTarget) {
            return
        }

        this.searchTarget.focus()
        this.searchTarget.select()
    }

    // ============================================================
    // PERSISTENCE
    // ============================================================

    buildStorageKey() {
        return (
            "entity-comparison:" +
            window.location.pathname
        )
    }

    persistState() {
        try {
            window.sessionStorage.setItem(
                `${this.storageKey}:search`,
                this.searchTerm
            )

            window.sessionStorage.setItem(
                `${this.storageKey}:filter`,
                this.activeFilter
            )
        } catch (error) {
            // Storage is optional.
        }
    }

    restoreState() {
        const params =
            new URLSearchParams(
                window.location.search
            )

        const storedSearch =
            window.sessionStorage.getItem(
                `${this.storageKey}:search`
            )

        const storedFilter =
            window.sessionStorage.getItem(
                `${this.storageKey}:filter`
            )

        this.searchTerm =
            params.get(
                "comparison_search"
            ) ||
            storedSearch ||
            ""

        this.activeFilter =
            params.get(
                "comparison_filter"
            ) ||
            storedFilter ||
            "all"

        if (this.hasSearchTarget) {
            this.searchTarget.value =
                this.searchTerm
        }

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value =
                this.activeFilter
        }
    }

    // ============================================================
    // UI HELPERS
    // ============================================================

    animateResultChange() {
        this.element.classList.remove(
            "entity-comparison--updated"
        )

        requestAnimationFrame(() => {
            this.element.classList.add(
                "entity-comparison--updated"
            )
        })
    }

    showCommand(message) {
        if (!this.hasCommandTarget) {
            return
        }

        this.commandTarget.textContent =
            message
    }
}