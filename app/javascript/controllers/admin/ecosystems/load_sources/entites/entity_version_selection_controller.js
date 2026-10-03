import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "form",
        "oldVersion",
        "newVersion",
        "submitButton",
        "error"
    ]

    connect() {
        this.clearError()
        this.updateSubmitState()
    }

    versionsChanged() {
        this.clearError()
        this.updateSubmitState()
    }

    submit(event) {
        const oldVersion = this.oldVersionTarget.value
        const newVersion = this.newVersionTarget.value

        if (!oldVersion || !newVersion) {
            event.preventDefault()

            this.showError(
                "Please select both an old version and a new version."
            )

            return
        }

        if (oldVersion === newVersion) {
            event.preventDefault()

            this.showError(
                "The old version and new version must be different."
            )

            return
        }

        this.clearError()
    }

    reset() {
        const url = new URL(window.location.href)

        url.searchParams.delete("from_version")
        url.searchParams.delete("to_version")

        window.location.assign(url.toString())
    }

    updateSubmitState() {
        if (!this.hasSubmitButtonTarget) {
            return
        }

        const oldVersion = this.oldVersionTarget.value
        const newVersion = this.newVersionTarget.value

        const hasBothVersions =
            oldVersion.length > 0 &&
            newVersion.length > 0

        const versionsAreDifferent =
            oldVersion.length === 0 ||
            newVersion.length === 0 ||
            oldVersion !== newVersion

        this.submitButtonTarget.disabled =
            !hasBothVersions ||
            !versionsAreDifferent
    }

    showError(message) {
        if (!this.hasErrorTarget) {
            return
        }

        this.errorTarget.textContent = message
        this.errorTarget.hidden = false
    }

    clearError() {
        if (!this.hasErrorTarget) {
            return
        }

        this.errorTarget.textContent = ""
        this.errorTarget.hidden = true
    }
}