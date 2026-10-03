import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "form",
        "oldVersion",
        "newVersion",
        "fromVersion",
        "toVersion",
        "compareButton",
        "error"
    ]

    connect() {
        this.syncSelection()
    }

    oldVersionChanged() {
        this.syncSelection()
    }

    newVersionChanged() {
        this.syncSelection()
    }

    submit(event) {
        this.syncSelection()

        const oldVersion = this.selectedOldVersion()
        const newVersion = this.selectedNewVersion()

        if (!oldVersion || !newVersion) {
            event.preventDefault()
            this.showError("Please select two different versions.")
            return
        }

        if (oldVersion === newVersion) {
            event.preventDefault()
            this.showError("The old and new versions must be different.")
            return
        }

        this.hideError()

        if (this.hasFromVersionTarget) {
            this.fromVersionTarget.value = oldVersion
        }

        if (this.hasToVersionTarget) {
            this.toVersionTarget.value = newVersion
        }
    }

    syncSelection() {
        const oldVersion = this.selectedOldVersion()
        const newVersion = this.selectedNewVersion()

        if (this.hasFromVersionTarget) {
            this.fromVersionTarget.value = oldVersion || ""
        }

        if (this.hasToVersionTarget) {
            this.toVersionTarget.value = newVersion || ""
        }

        const valid =
            oldVersion &&
            newVersion &&
            oldVersion !== newVersion

        if (this.hasCompareButtonTarget) {
            this.compareButtonTarget.disabled = !valid
        }

        this.updateVisualSelection(oldVersion, newVersion)

        if (valid) {
            this.hideError()
        }
    }

    selectedOldVersion() {
        const selected = this.oldVersionTargets.find(
            (input) => input.checked
        )

        return selected ? selected.value : null
    }

    selectedNewVersion() {
        const selected = this.newVersionTargets.find(
            (input) => input.checked
        )

        return selected ? selected.value : null
    }

    updateVisualSelection(oldVersion, newVersion) {
        const rows = this.element.querySelectorAll(
            "[data-entity-version-history-row]"
        )

        rows.forEach((row) => {
            const versionId =
                row.dataset.versionId

            row.classList.toggle(
                "entity-version-history__row--selected-old",
                Boolean(oldVersion && versionId === oldVersion)
            )

            row.classList.toggle(
                "entity-version-history__row--selected-new",
                Boolean(newVersion && versionId === newVersion)
            )
        })
    }

    showError(message) {
        if (!this.hasErrorTarget) {
            return
        }

        this.errorTarget.textContent = message
        this.errorTarget.hidden = false
    }

    hideError() {
        if (!this.hasErrorTarget) {
            return
        }

        this.errorTarget.hidden = true
    }
}