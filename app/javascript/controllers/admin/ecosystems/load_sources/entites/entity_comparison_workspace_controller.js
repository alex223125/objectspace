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
        "achievement",
        "achievementTitle",
        "achievementText",
        "activity",
        "activityCount",
        "focusMode",
        "focusLabel"
    ]

    connect() {
        this.activeFilter = "all"
        this.activityCountValue = 0
        this.focusModeEnabled = false

        this.initializeRows()
        this.update()
    }

    initializeRows() {
        this.rows = this.hasRowTarget
            ? this.rowTargets
            : []
    }

    searchChanged() {
        this.update()
    }

    typeChanged() {
        this.update()
    }

    reset() {
        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasTypeFilterTarget) {
            this.typeFilterTarget.value = "all"
        }

        this.recordActivity(
            "Filters reset",
            "Comparison workspace returned to the full dataset."
        )

        this.update()
    }

    update() {
        const query = this.hasSearchTarget
            ? this.normalize(this.searchTarget.value)
            : ""

        const type = this.hasTypeFilterTarget
            ? this.typeFilterTarget.value || "all"
            : "all"

        let visible = 0

        this.rows.forEach((row) => {
            const searchable = this.searchableText(row)
            const rowType = row.dataset.changeType || ""

            const matchesSearch =
                !query ||
                searchable.includes(query)

            const matchesType =
                type === "all" ||
                rowType === type

            const shouldShow =
                matchesSearch &&
                matchesType

            row.hidden = !shouldShow

            row.setAttribute(
                "aria-hidden",
                shouldShow ? "false" : "true"
            )

            if (shouldShow) {
                visible += 1
            }
        })

        this.updateCounters(visible)
        this.updateProgress(visible)
        this.updateEmptyState(visible)
        this.checkAchievements(visible)
    }

    searchableText(row) {
        return this.normalize(
            [
                row.dataset.comparisonPath,
                row.dataset.comparisonIdentity,
                row.dataset.oldValue,
                row.dataset.newValue,
                row.textContent
            ]
                .filter(
                    value =>
                        value !== undefined &&
                        value !== null
                )
                .join(" ")
        )
    }

    normalize(value) {
        return String(value || "")
            .trim()
            .toLowerCase()
    }

    updateCounters(visible) {
        if (this.hasVisibleCountTarget) {
            this.visibleCountTarget.textContent =
                String(visible)
        }

        if (this.hasTotalCountTarget) {
            this.totalCountTarget.textContent =
                String(this.rows.length)
        }
    }

    updateProgress(visible) {
        const total = this.rows.length

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
                `${percentage}% of comparison visible`
        }
    }

    updateEmptyState(visible) {
        if (!this.hasEmptyTarget) {
            return
        }

        this.emptyTarget.hidden =
            visible !== 0
    }

    toggleFocusMode() {
        this.focusModeEnabled =
            !this.focusModeEnabled

        this.element.classList.toggle(
            "comparison-workspace--focus",
            this.focusModeEnabled
        )

        if (this.hasFocusLabelTarget) {
            this.focusLabelTarget.textContent =
                this.focusModeEnabled
                    ? "Exit focus"
                    : "Focus mode"
        }

        this.recordActivity(
            this.focusModeEnabled
                ? "Focus mode enabled"
                : "Focus mode disabled",
            this.focusModeEnabled
                ? "Comparison distractions were reduced."
                : "Full comparison workspace restored."
        )
    }

    inspectRow(event) {
        const row =
            event.currentTarget.closest(
                "[data-comparison-row]"
            )

        if (!row) {
            return
        }

        row.classList.add(
            "comparison-row--inspected"
        )

        setTimeout(() => {
            row.classList.remove(
                "comparison-row--inspected"
            )
        }, 900)

        const path =
            row.dataset.comparisonPath ||
            "comparison item"

        this.recordActivity(
            "Comparison inspected",
            path
        )
    }

    recordActivity(title, text) {
        this.activityCountValue += 1

        if (this.hasActivityCountTarget) {
            this.activityCountTarget.textContent =
                String(this.activityCountValue)
        }

        if (!this.hasActivityTarget) {
            return
        }

        const item =
            document.createElement("div")

        item.className =
            "comparison-activity-item"

        item.innerHTML = `
            <div class="comparison-activity-dot"></div>
            <div class="min-w-0">
                <div class="comparison-activity-title">
                    ${this.escapeHtml(title)}
                </div>
                <div class="comparison-activity-text">
                    ${this.escapeHtml(text)}
                </div>
            </div>
        `

        this.activityTarget.prepend(item)

        while (
            this.activityTarget.children.length > 5
            ) {
            this.activityTarget.lastElementChild.remove()
        }
    }

    checkAchievements(visible) {
        if (
            visible === 0 ||
            !this.hasAchievementTarget
        ) {
            return
        }

        const percentage =
            this.rows.length === 0
                ? 0
                : Math.round(
                    (visible / this.rows.length) * 100
                )

        if (percentage < 50) {
            return
        }

        this.unlockAchievement(
            "Signal Explorer",
            "You explored more than half of the comparison surface."
        )
    }

    unlockAchievement(title, text) {
        if (
            this.achievementTarget.dataset.unlocked ===
            title
        ) {
            return
        }

        this.achievementTarget.dataset.unlocked =
            title

        if (this.hasAchievementTitleTarget) {
            this.achievementTitleTarget.textContent =
                title
        }

        if (this.hasAchievementTextTarget) {
            this.achievementTextTarget.textContent =
                text
        }

        this.achievementTarget.hidden = false

        this.recordActivity(
            `Achievement unlocked: ${title}`,
            text
        )
    }

    escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }
}