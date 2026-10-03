import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "progress",
        "progressLabel",
        "xp",
        "mission",
        "missionLabel",
        "category",
        "categoryCount",
        "status",
        "toast",
        "toastMessage"
    ]

    static values = {
        storageKey: {
            type: String,
            default: "entity-comparison-experience"
        }
    }

    connect() {
        this.state = {
            viewed: new Set(),
            categories: new Set(),
            xp: 0,
            startedAt: Date.now()
        }

        this.restoreState()
        this.bindRows()
        this.bindKeyboard()
        this.refresh()
    }

    disconnect() {
        this.unbindRows()
        this.unbindKeyboard()
        this.saveState()
    }

    // ============================================================
    // INITIALIZATION
    // ============================================================

    bindRows() {
        this.rows =
            Array.from(
                this.element.querySelectorAll(
                    "[data-comparison-row]"
                )
            )

        this.rowHandlers = new Map()

        this.rows.forEach((row, index) => {
            const handler = () => {
                this.inspectRow(row, index)
            }

            row.addEventListener("click", handler)

            this.rowHandlers.set(row, handler)
        })
    }

    unbindRows() {
        if (!this.rows || !this.rowHandlers) {
            return
        }

        this.rows.forEach((row) => {
            const handler = this.rowHandlers.get(row)

            if (handler) {
                row.removeEventListener("click", handler)
            }
        })
    }

    bindKeyboard() {
        this.keyboardHandler =
            (event) => this.handleKeyboard(event)

        document.addEventListener(
            "keydown",
            this.keyboardHandler
        )
    }

    unbindKeyboard() {
        if (!this.keyboardHandler) {
            return
        }

        document.removeEventListener(
            "keydown",
            this.keyboardHandler
        )
    }

    // ============================================================
    // ROW INTERACTION
    // ============================================================

    inspectRow(row, index) {
        const key =
            row.dataset.comparisonIdentity ||
            row.dataset.comparisonPath ||
            String(index)

        if (this.state.viewed.has(key)) {
            return
        }

        this.state.viewed.add(key)

        const type =
            row.dataset.changeType ||
            "content_change"

        this.state.categories.add(type)

        this.state.xp += this.xpForType(type)

        row.classList.add(
            "entity-comparison-row--discovered"
        )

        window.setTimeout(() => {
            row.classList.remove(
                "entity-comparison-row--discovered"
            )
        }, 900)

        this.showToast(
            `Discovery unlocked · +${this.xpForType(type)} XP`
        )

        this.refresh()
        this.saveState()
    }

    xpForType(type) {
        switch (type) {
            case "semantic_movement":
                return 15

            case "identity_warning":
                return 20

            case "added_entity":
                return 10

            case "removed_entity":
                return 10

            case "content_change":
                return 5

            default:
                return 5
        }
    }

    // ============================================================
    // PROGRESS
    // ============================================================

    refresh() {
        const total =
            this.rows
                ? this.rows.length
                : 0

        const viewed =
            this.state.viewed.size

        const percentage =
            total === 0
                ? 0
                : Math.min(
                    100,
                    Math.round(
                        (viewed / total) * 100
                    )
                )

        this.updateProgress(percentage)
        this.updateXp()
        this.updateMission(
            percentage,
            viewed,
            total
        )
        this.updateCategories()
        this.updateStatus(
            percentage,
            viewed,
            total
        )
    }

    updateProgress(percentage) {
        if (this.hasProgressTarget) {
            this.progressTarget.style.width =
                `${percentage}%`

            this.progressTarget.setAttribute(
                "aria-valuenow",
                String(percentage)
            )
        }

        if (this.hasProgressLabelTarget) {
            this.progressLabelTarget.textContent =
                `${percentage}% explored`
        }
    }

    updateXp() {
        if (!this.hasXpTarget) {
            return
        }

        this.xpTarget.textContent =
            this.state.xp.toLocaleString()
    }

    updateMission(
        percentage,
        viewed,
        total
    ) {
        if (!this.hasMissionTarget) {
            return
        }

        let label =
            "Begin your comparison journey"

        if (total === 0) {
            label =
                "No comparison facts available"
        } else if (percentage >= 100) {
            label =
                "Comparison fully explored"
        } else if (percentage >= 75) {
            label =
                "Final discoveries remaining"
        } else if (percentage >= 50) {
            label =
                "Halfway through the comparison"
        } else if (percentage >= 25) {
            label =
                "Discovery momentum established"
        } else if (viewed > 0) {
            label =
                "First discovery unlocked"
        }

        this.missionTarget.textContent =
            label

        if (this.hasMissionLabelTarget) {
            this.missionLabelTarget.textContent =
                total === 0
                    ? "Nothing to explore yet"
                    : `${viewed} of ${total} discoveries explored`
        }
    }

    updateCategories() {
        if (
            !this.hasCategoryTarget &&
            !this.hasCategoryCountTarget
        ) {
            return
        }

        const count =
            this.state.categories.size

        if (this.hasCategoryCountTarget) {
            this.categoryCountTarget.textContent =
                String(count)
        }

        if (this.hasCategoryTarget) {
            this.categoryTarget.textContent =
                `${count} change type${count === 1 ? "" : "s"} discovered`
        }
    }

    updateStatus(
        percentage,
        viewed,
        total
    ) {
        if (!this.hasStatusTarget) {
            return
        }

        if (total === 0) {
            this.statusTarget.textContent =
                "Ready"
            return
        }

        if (percentage >= 100) {
            this.statusTarget.textContent =
                "Complete"
            return
        }

        if (viewed > 0) {
            this.statusTarget.textContent =
                "Exploring"
            return
        }

        this.statusTarget.textContent =
            "Ready"
    }

    // ============================================================
    // TOAST
    // ============================================================

    showToast(message) {
        if (
            !this.hasToastTarget ||
            !this.hasToastMessageTarget
        ) {
            return
        }

        this.toastMessageTarget.textContent =
            message

        this.toastTarget.hidden = false

        window.clearTimeout(
            this.toastTimer
        )

        this.toastTimer =
            window.setTimeout(() => {
                this.toastTarget.hidden = true
            }, 2400)
    }

    // ============================================================
    // KEYBOARD NAVIGATION
    // ============================================================

    handleKeyboard(event) {
        const tag =
            event.target?.tagName

        if (
            tag === "INPUT" ||
            tag === "TEXTAREA" ||
            tag === "SELECT"
        ) {
            return
        }

        if (event.key === "?") {
            this.showToast(
                "Shortcuts: 1 Changes · 2 Movements · 3 Added · 4 Removed · 5 Warnings"
            )

            return
        }

        const shortcutMap = {
            "1": "content_change",
            "2": "semantic_movement",
            "3": "added_entity",
            "4": "removed_entity",
            "5": "identity_warning"
        }

        const type =
            shortcutMap[event.key]

        if (!type) {
            return
        }

        const filter =
            this.element.querySelector(
                `[data-comparison-type-filter]`
            )

        if (!filter) {
            return
        }

        filter.value = type

        filter.dispatchEvent(
            new Event("change", {
                bubbles: true
            })
        )

        this.showToast(
            `Showing ${this.labelForType(type)}`
        )
    }

    labelForType(type) {
        switch (type) {
            case "content_change":
                return "content changes"

            case "semantic_movement":
                return "semantic movements"

            case "added_entity":
                return "additions"

            case "removed_entity":
                return "removals"

            case "identity_warning":
                return "identity warnings"

            default:
                return "changes"
        }
    }

    // ============================================================
    // PERSISTENCE
    // ============================================================

    saveState() {
        try {
            const payload = {
                viewed: Array.from(
                    this.state.viewed
                ),
                categories: Array.from(
                    this.state.categories
                ),
                xp: this.state.xp
            }

            window.localStorage.setItem(
                this.storageKeyValue,
                JSON.stringify(payload)
            )
        } catch (error) {
            // Local storage may be unavailable.
        }
    }

    restoreState() {
        try {
            const raw =
                window.localStorage.getItem(
                    this.storageKeyValue
                )

            if (!raw) {
                return
            }

            const payload =
                JSON.parse(raw)

            if (
                Array.isArray(
                    payload.viewed
                )
            ) {
                this.state.viewed =
                    new Set(payload.viewed)
            }

            if (
                Array.isArray(
                    payload.categories
                )
            ) {
                this.state.categories =
                    new Set(payload.categories)
            }

            if (
                Number.isFinite(
                    Number(payload.xp)
                )
            ) {
                this.state.xp =
                    Number(payload.xp)
            }
        } catch (error) {
            // Ignore malformed local state.
        }
    }
}