import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search",
        "typeFilter",
        "row",
        "visibleCount",
        "totalCount",
        "empty",
        "progress",
        "progressLabel",
        "xp",
        "insight",
        "filterChip"
    ]

    static values = {
        storageKey: {
            type: String,
            default: "entity-comparison-explorer"
        }
    }

    connect() {
        this.activeFilter = "all"
        this.searchQuery = ""

        this.restoreState()
        this.bindKeyboard()
        this.applyFilters()
    }

    disconnect() {
        this.unbindKeyboard()
    }

    // ============================================================
    // SEARCH
    // ============================================================

    searchChanged() {
        this.searchQuery = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : ""

        this.applyFilters()
        this.persistState()
    }

    typeFilterChanged(event) {
        this.activeFilter =
            event.currentTarget.value || "all"

        this.applyFilters()
        this.persistState()
    }

    // ============================================================
    // FILTERING
    // ============================================================

    applyFilters() {
        const query = this.searchQuery

        const type =
            this.activeFilter || "all"

        let visible = 0

        this.rowTargets.forEach((row) => {
            const searchableText =
                this.searchableText(row)

            const rowType =
                row.dataset.changeType || ""

            const matchesSearch =
                !query ||
                searchableText.includes(query)

            const matchesType =
                type === "all" ||
                rowType === type

            const shouldShow =
                matchesSearch &&
                matchesType

            row.hidden = !shouldShow

            row.setAttribute(
                "aria-hidden",
                String(!shouldShow)
            )

            if (shouldShow) {
                visible += 1
            }
        })

        this.updateCounters(visible)
        this.updateEmptyState(visible)
        this.updateProgress(visible)
        this.updateInsights(visible)
        this.updateFilterChips()
    }

    searchableText(row) {
        return [
            row.dataset.comparisonPath,
            row.dataset.comparisonIdentity,
            row.dataset.oldValue,
            row.dataset.newValue,
            row.dataset.changeType,
            row.textContent
        ]
            .filter(
                (value) =>
                    value !== undefined &&
                    value !== null
            )
            .join(" ")
            .trim()
            .toLowerCase()
    }

    // ============================================================
    // COUNTERS
    // ============================================================

    updateCounters(visible) {
        if (this.hasVisibleCountTarget) {
            this.visibleCountTarget.textContent =
                String(visible)
        }

        if (this.hasTotalCountTarget) {
            this.totalCountTarget.textContent =
                String(this.rowTargets.length)
        }
    }

    updateEmptyState(visible) {
        if (!this.hasEmptyTarget) {
            return
        }

        this.emptyTarget.hidden =
            visible !== 0
    }

    // ============================================================
    // PROGRESS / GAMIFICATION
    // ============================================================

    updateProgress(visible) {
        const total =
            this.rowTargets.length

        if (!total) {
            this.setProgress(0)
            return
        }

        const percentage =
            Math.round(
                (visible / total) * 100
            )

        this.setProgress(percentage)
    }

    setProgress(percentage) {
        const bounded =
            Math.max(
                0,
                Math.min(
                    100,
                    percentage
                )
            )

        if (this.hasProgressTarget) {
            this.progressTarget.style.width =
                `${bounded}%`
        }

        if (this.hasProgressLabelTarget) {
            this.progressLabelTarget.textContent =
                `${bounded}% explored`
        }
    }

    // ============================================================
    // XP
    // ============================================================

    awardExplorerXp(amount = 5) {
        const current =
            Number(
                localStorage.getItem(
                    `${this.storageKeyValue}:xp`
                ) || 0
            )

        const next =
            current + amount

        localStorage.setItem(
            `${this.storageKeyValue}:xp`,
            String(next)
        )

        this.renderXp(next)
    }

    renderXp(value) {
        if (!this.hasXpTarget) {
            return
        }

        this.xpTarget.textContent =
            `${value} XP`
    }

    // ============================================================
    // INSIGHTS
    // ============================================================

    updateInsights(visible) {
        if (!this.hasInsightTarget) {
            return
        }

        const total =
            this.rowTargets.length

        if (!total) {
            this.insightTarget.textContent =
                "No comparison facts are available yet."

            return
        }

        if (visible === 0) {
            this.insightTarget.textContent =
                "No facts match your current exploration filters."

            return
        }

        if (this.activeFilter !== "all") {
            this.insightTarget.textContent =
                `${visible} ${this.humanizeType(this.activeFilter)} currently visible.`
            return
        }

        this.insightTarget.textContent =
            `${total} comparison facts are available to explore.`
    }

    humanizeType(type) {
        const labels = {
            content_change: "content changes",
            semantic_movement: "semantic movements",
            added_entity: "additions",
            removed_entity: "removals",
            identity_warning: "identity warnings"
        }

        return labels[type] || "facts"
    }

    // ============================================================
    // FILTER CHIPS
    // ============================================================

    updateFilterChips() {
        if (!this.hasFilterChipTarget) {
            return
        }

        this.filterChipTargets.forEach((chip) => {
            const active =
                chip.dataset.filter ===
                this.activeFilter

            chip.classList.toggle(
                "bg-orange-500",
                active
            )

            chip.classList.toggle(
                "text-white",
                active
            )

            chip.classList.toggle(
                "border-orange-500",
                active
            )

            chip.classList.toggle(
                "bg-white",
                !active
            )

            chip.setAttribute(
                "aria-pressed",
                String(active)
            )
        })
    }

    chooseFilter(event) {
        const filter =
            event.currentTarget.dataset.filter ||
            "all"

        this.activeFilter = filter

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value =
                filter
        }

        this.applyFilters()
        this.persistState()

        this.awardExplorerXp(2)
    }

    // ============================================================
    // RESET
    // ============================================================

    reset() {
        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value = "all"
        }

        this.searchQuery = ""
        this.activeFilter = "all"

        this.applyFilters()
        this.persistState()

        if (this.hasSearchTarget) {
            this.searchTarget.focus()
        }

        this.awardExplorerXp(1)
    }

    // ============================================================
    // KEYBOARD SHORTCUTS
    // ============================================================

    bindKeyboard() {
        this.boundKeydown =
            (event) => this.handleKeydown(event)

        document.addEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    unbindKeyboard() {
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
            target instanceof HTMLInputElement ||
            target instanceof HTMLTextAreaElement ||
            target instanceof HTMLSelectElement

        if (isTyping) {
            if (event.key === "Escape") {
                target.blur()
            }

            return
        }

        if (event.key === "/") {
            event.preventDefault()

            if (this.hasSearchTarget) {
                this.searchTarget.focus()
            }

            return
        }

        if (
            event.key.toLowerCase() ===
            "r"
        ) {
            event.preventDefault()
            this.reset()
            return
        }

        if (event.key === "1") {
            event.preventDefault()
            this.setKeyboardFilter("all")
            return
        }

        if (event.key === "2") {
            event.preventDefault()
            this.setKeyboardFilter(
                "content_change"
            )
            return
        }

        if (event.key === "3") {
            event.preventDefault()
            this.setKeyboardFilter(
                "semantic_movement"
            )
            return
        }

        if (event.key === "4") {
            event.preventDefault()
            this.setKeyboardFilter(
                "added_entity"
            )
            return
        }

        if (event.key === "5") {
            event.preventDefault()
            this.setKeyboardFilter(
                "removed_entity"
            )
            return
        }
    }

    setKeyboardFilter(filter) {
        this.activeFilter = filter

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value =
                filter
        }

        this.applyFilters()
        this.persistState()
        this.awardExplorerXp(2)
    }

    // ============================================================
    // URL / LOCAL STATE
    // ============================================================

    persistState() {
        const state = {
            search: this.searchQuery,
            filter: this.activeFilter
        }

        localStorage.setItem(
            `${this.storageKeyValue}:state`,
            JSON.stringify(state)
        )

        const url =
            new URL(window.location.href)

        if (this.searchQuery) {
            url.searchParams.set(
                "comparison_search",
                this.searchQuery
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

        window.history.replaceState(
            {},
            "",
            url.toString()
        )
    }

    restoreState() {
        const url =
            new URL(window.location.href)

        let search =
            url.searchParams.get(
                "comparison_search"
            )

        let filter =
            url.searchParams.get(
                "comparison_filter"
            )

        if (!search && !filter) {
            try {
                const saved =
                    JSON.parse(
                        localStorage.getItem(
                            `${this.storageKeyValue}:state`
                        ) || "{}"
                    )

                search =
                    saved.search || ""

                filter =
                    saved.filter || "all"
            } catch {
                search = ""
                filter = "all"
            }
        }

        this.searchQuery =
            String(search || "")
                .trim()
                .toLowerCase()

        this.activeFilter =
            filter || "all"

        if (this.hasSearchTarget) {
            this.searchTarget.value =
                this.searchQuery
        }

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value =
                this.activeFilter
        }

        this.renderXp(
            Number(
                localStorage.getItem(
                    `${this.storageKeyValue}:xp`
                ) || 0
            )
        )
    }
}