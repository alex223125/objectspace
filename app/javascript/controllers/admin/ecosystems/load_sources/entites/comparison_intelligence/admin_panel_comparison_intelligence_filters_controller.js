
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "control",
        "item",
        "count",
        "emptyState",
        "status"
    ]

    connect() {
        this.apply()
    }

    change() {
        this.apply()
    }

    reset(event) {
        event?.preventDefault()

        this.controlTargets.forEach(control => {
            if (control.type === "checkbox" || control.type === "radio") {
                control.checked = false
            } else {
                control.value = ""
            }
        })

        this.apply()
    }

    apply() {
        const filters = {}

        this.controlTargets.forEach(control => {
            const key = control.dataset.filterKey
            if (!key) return

            const value = control.type === "checkbox"
                ? (control.checked ? control.value || "true" : "")
                : control.value

            if (value) filters[key] = value.toLowerCase()
        })

        let visibleCount = 0

        this.itemTargets.forEach(item => {
            const visible = Object.entries(filters).every(([key, expected]) => {
                const actual = (item.dataset[key] || "").toLowerCase()

                if (expected === "all") return true

                return actual === expected
            })

            item.hidden = !visible

            if (visible) visibleCount += 1
        })

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visibleCount} ${visibleCount === 1 ? "change" : "changes"}`
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visibleCount > 0
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                `${visibleCount} changes match the selected filters`
        }

        this.dispatch("applied", {
            detail: {
                filters,
                visibleCount,
                totalCount: this.itemTargets.length
            }
        })
    }
}