import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "rows",
        "row",
        "template",
        "submitButton",
        "submitLabel",
        "spinner",
        "emptyState",
        "count"
    ]

    connect() {
        this.refresh()
    }

    addRow(event) {
        event.preventDefault()

        const template = this.templateTarget.innerHTML
            .replace(/NEW_RECORD/g, this.nextIndex())

        this.rowsTarget.insertAdjacentHTML(
            "beforeend",
            template
        )

        this.refresh()

        const rows = this.rowTargets

        if (rows.length === 0) {
            return
        }

        const lastRow = rows[rows.length - 1]

        const pathInput =
            lastRow.querySelector("[data-role='path-input']")

        if (pathInput) {
            requestAnimationFrame(() => {
                pathInput.focus()
            })
        }
    }

    removeRow(event) {
        event.preventDefault()

        const row =
            event.currentTarget.closest(
                "[data-diff-intelligence-target='row']"
            )

        if (!row) {
            return
        }

        row.remove()

        this.refresh()
    }

    handleSubmit() {
        this.submitButtonTarget.disabled = true

        this.submitButtonTarget.classList.add(
            "opacity-80",
            "cursor-wait"
        )

        if (this.hasSubmitLabelTarget) {
            this.submitLabelTarget.textContent =
                "Saving configuration..."
        }

        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.remove("hidden")
        }
    }

    refresh() {
        this.updateCount()
        this.updateEmptyState()
    }

    updateCount() {
        if (!this.hasCountTarget) {
            return
        }

        const count = this.rowTargets.length

        this.countTarget.textContent =
            `${count} ${count === 1 ? "identity rule" : "identity rules"}`
    }

    updateEmptyState() {
        if (!this.hasEmptyStateTarget) {
            return
        }

        this.emptyStateTarget.classList.toggle(
            "hidden",
            this.rowTargets.length > 0
        )
    }

    nextIndex() {
        return `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`
    }
}