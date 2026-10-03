import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "progress",
        "progressBar",
        "reviewedCount",
        "totalCount",
        "remainingCount",
        "xp",
        "level",
        "streak",
        "reviewedRows",
        "empty"
    ]

    static values = {
        storageKey: {
            type: String,
            default: "entity-comparison-progress"
        }
    }

    connect() {
        this.reviewed = new Set()
        this.currentIndex = 0

        this.loadState()
        this.bindKeyboard()
        this.refresh()
    }

    disconnect() {
        this.unbindKeyboard()
    }

    // ============================================================
    // STATE
    // ============================================================

    loadState() {
        try {
            const raw =
                window.localStorage.getItem(
                    this.storageKey()
                )

            if (!raw) {
                return
            }

            const parsed =
                JSON.parse(raw)

            if (
                Array.isArray(
                    parsed.reviewed
                )
            ) {
                this.reviewed =
                    new Set(parsed.reviewed)
            }
        } catch (error) {
            console.warn(
                "Unable to restore comparison progress.",
                error
            )
        }
    }

    saveState() {
        try {
            window.localStorage.setItem(
                this.storageKey(),
                JSON.stringify({
                    reviewed: Array.from(
                        this.reviewed
                    )
                })
            )
        } catch (error) {
            console.warn(
                "Unable to save comparison progress.",
                error
            )
        }
    }

    storageKey() {
        return this.hasStorageKeyValue
            ? this.storageKeyValue
            : "entity-comparison-progress"
    }

    // ============================================================
    // ROWS
    // ============================================================

    rows() {
        return Array.from(
            this.element.querySelectorAll(
                "[data-comparison-row]"
            )
        )
    }

    visibleRows() {
        return this.rows().filter(
            (row) => !row.hidden
        )
    }

    reviewKey(row) {
        return (
            row.dataset.reviewKey ||
            row.dataset.comparisonIdentity ||
            row.dataset.comparisonPath ||
            ""
        )
    }

    // ============================================================
    // REVIEW ACTION
    // ============================================================

    toggleReviewed(event) {
        const button =
            event.currentTarget

        const row =
            button.closest(
                "[data-comparison-row]"
            )

        if (!row) {
            return
        }

        const key =
            this.reviewKey(row)

        if (!key) {
            return
        }

        if (this.reviewed.has(key)) {
            this.reviewed.delete(key)
        } else {
            this.reviewed.add(key)
        }

        this.saveState()
        this.refresh()
    }

    resetProgress() {
        this.reviewed.clear()

        this.saveState()
        this.refresh()
    }

    // ============================================================
    // REFRESH
    // ============================================================

    refresh() {
        const rows =
            this.rows()

        const total =
            rows.length

        const reviewed =
            rows.filter((row) =>
                this.reviewed.has(
                    this.reviewKey(row)
                )
            ).length

        const remaining =
            Math.max(
                total - reviewed,
                0
            )

        const percentage =
            total === 0
                ? 0
                : Math.round(
                    (reviewed / total) *
                    100
                )

        const experience =
            this.calculateExperience(
                reviewed
            )

        this.updateText(
            this.hasReviewedCountTarget,
            reviewed
        )

        this.updateText(
            this.hasTotalCountTarget,
            total
        )

        this.updateText(
            this.hasRemainingCountTarget,
            remaining
        )

        this.updateText(
            this.hasXpTarget,
            experience.xp
        )

        this.updateText(
            this.hasLevelTarget,
            experience.level
        )

        this.updateText(
            this.hasStreakTarget,
            experience.streak
        )

        if (this.hasProgressTarget) {
            this.progressTarget.textContent =
                `${percentage}%`
        }

        if (this.hasProgressBarTarget) {
            this.progressBarTarget.style.width =
                `${percentage}%`

            this.progressBarTarget.setAttribute(
                "aria-valuenow",
                String(percentage)
            )
        }

        rows.forEach((row) => {
            this.updateRow(
                row
            )
        })

        if (this.hasReviewedRowsTarget) {
            this.reviewedRowsTarget.textContent =
                `${reviewed} reviewed`
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.hidden =
                total !== 0
        }
    }

    updateRow(row) {
        const key =
            this.reviewKey(row)

        const reviewed =
            Boolean(
                key &&
                this.reviewed.has(key)
            )

        row.dataset.reviewed =
            reviewed
                ? "true"
                : "false"

        row.classList.toggle(
            "opacity-70",
            reviewed
        )

        row.classList.toggle(
            "ring-2",
            reviewed
        )

        row.classList.toggle(
            "ring-emerald-100",
            reviewed
        )

        const button =
            row.querySelector(
                "[data-comparison-review-button]"
            )

        if (!button) {
            return
        }

        button.setAttribute(
            "aria-pressed",
            String(reviewed)
        )

        button.textContent =
            reviewed
                ? "✓ Reviewed"
                : "Mark reviewed"

        button.classList.toggle(
            "bg-emerald-50",
            reviewed
        )

        button.classList.toggle(
            "text-emerald-700",
            reviewed
        )

        button.classList.toggle(
            "border-emerald-200",
            reviewed
        )
    }

    // ============================================================
    // EXPERIENCE
    // ============================================================

    calculateExperience(reviewed) {
        const xp =
            reviewed * 25

        const level =
            Math.max(
                1,
                Math.floor(
                    xp / 250
                ) + 1
            )

        /*
         * The streak here represents
         * completed review actions in
         * this comparison session.
         *
         * It deliberately does not pretend
         * to be a real daily streak.
         */
        const streak =
            reviewed === 0
                ? 0
                : Math.min(
                    reviewed,
                    7
                )

        return {
            xp,
            level,
            streak
        }
    }

    // ============================================================
    // KEYBOARD NAVIGATION
    // ============================================================

    bindKeyboard() {
        this.boundKeydown =
            (event) =>
                this.handleKeydown(event)

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
        if (
            this.isTypingContext(
                event.target
            )
        ) {
            return
        }

        const key =
            event.key.toLowerCase()

        if (key === "j") {
            event.preventDefault()
            this.moveSelection(1)
            return
        }

        if (key === "k") {
            event.preventDefault()
            this.moveSelection(-1)
            return
        }

        if (key === "r") {
            event.preventDefault()
            this.reviewCurrent()
            return
        }

        if (key === "/") {
            event.preventDefault()

            const search =
                this.element.querySelector(
                    "[data-comparison-search]"
                )

            search?.focus()

            return
        }
    }

    isTypingContext(element) {
        if (!element) {
            return false
        }

        const tag =
            element.tagName?.toLowerCase()

        return (
            tag === "input" ||
            tag === "textarea" ||
            tag === "select" ||
            element.isContentEditable
        )
    }

    moveSelection(direction) {
        const rows =
            this.visibleRows()

        if (!rows.length) {
            return
        }

        this.currentIndex =
            Math.min(
                Math.max(
                    this.currentIndex +
                    direction,
                    0
                ),
                rows.length - 1
            )

        const row =
            rows[this.currentIndex]

        row.scrollIntoView({
            behavior: "smooth",
            block: "center"
        })

        rows.forEach(
            (item) => {
                item.classList.remove(
                    "ring-2",
                    "ring-violet-200"
                )
            }
        )

        row.classList.add(
            "ring-2",
            "ring-violet-200"
        )
    }

    reviewCurrent() {
        const rows =
            this.visibleRows()

        if (!rows.length) {
            return
        }

        const row =
            rows[
                Math.min(
                    this.currentIndex,
                    rows.length - 1
                )
                ]

        const button =
            row.querySelector(
                "[data-comparison-review-button]"
            )

        button?.click()
    }

    // ============================================================
    // HELPERS
    // ============================================================

    updateText(
        targetExists,
        value
    ) {
        if (
            typeof targetExists !==
            "object"
        ) {
            return
        }

        targetExists.textContent =
            String(value)
    }


    markReviewed(event) {
        // existing review logic

        this.element
            .querySelectorAll(
                "[data-controller~='comparison-intelligence']"
            )
            .forEach((element) => {
                const controller =
                    this.application.getControllerForElementAndIdentifier(
                        element,
                        "comparison-intelligence"
                    )

                controller?.refresh()
            })
    }


}