import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "form",
        "oldVersion",
        "newVersion",
        "submitButton",
        "error",
        "status"
    ]

    static values = {
        defaultOld: String,
        defaultNew: String
    }

    connect() {
        this.validateSelection()
    }

    submit(event) {
        if (!this.validateSelection()) {
            event.preventDefault()
            return
        }

        this.setSubmittingState()
    }

    versionChanged() {
        this.validateSelection()
    }

    validateSelection() {
        if (
            !this.hasOldVersionTarget ||
            !this.hasNewVersionTarget
        ) {
            return true
        }

        const oldVersion =
            this.oldVersionTarget.value

        const newVersion =
            this.newVersionTarget.value

        if (!oldVersion || !newVersion) {
            this.showError(
                "Select both versions to compare."
            )

            this.setStatus(
                "Waiting for versions",
                "warning"
            )

            return false
        }

        if (oldVersion === newVersion) {
            this.showError(
                "The old and new versions must be different."
            )

            this.setStatus(
                "Choose two different versions",
                "error"
            )

            return false
        }

        this.clearError()

        this.setStatus(
            "Ready to compare",
            "success"
        )

        return true
    }

    reset(event) {
        event?.preventDefault()

        const oldVersion =
            this.defaultOldValue ||
            this.firstVersionValue()

        const newVersion =
            this.defaultNewValue ||
            this.lastVersionValue()

        if (
            this.hasOldVersionTarget &&
            oldVersion
        ) {
            this.oldVersionTarget.value =
                oldVersion
        }

        if (
            this.hasNewVersionTarget &&
            newVersion
        ) {
            this.newVersionTarget.value =
                newVersion
        }

        this.clearError()
        this.resetSubmittingState()

        this.navigateToDefaultComparison()
    }

    setSubmittingState() {
        if (!this.hasSubmitButtonTarget) {
            return
        }

        this.submitButtonTarget.disabled = true

        this.submitButtonTarget.setAttribute(
            "aria-disabled",
            "true"
        )

        this.submitButtonTarget.dataset.originalText =
            this.submitButtonTarget.textContent

        this.submitButtonTarget.textContent =
            "Comparing…"
    }

    resetSubmittingState() {
        if (!this.hasSubmitButtonTarget) {
            return
        }

        this.submitButtonTarget.disabled = false

        this.submitButtonTarget.removeAttribute(
            "aria-disabled"
        )

        const original =
            this.submitButtonTarget.dataset.originalText

        this.submitButtonTarget.textContent =
            original || "Compare versions"

        delete this.submitButtonTarget.dataset.originalText
    }

    navigateToDefaultComparison() {
        const url =
            new URL(
                window.location.href
            )

        url.searchParams.delete(
            "from_version"
        )

        url.searchParams.delete(
            "to_version"
        )

        window.location.assign(
            url.toString()
        )
    }

    firstVersionValue() {
        if (!this.hasOldVersionTarget) {
            return ""
        }

        return (
            this.oldVersionTarget
                .options[0]
                ?.value || ""
        )
    }

    lastVersionValue() {
        if (!this.hasNewVersionTarget) {
            return ""
        }

        const options =
            this.newVersionTarget.options

        return options.length
            ? options[options.length - 1].value
            : ""
    }

    showError(message) {
        if (!this.hasErrorTarget) {
            return
        }

        this.errorTarget.textContent =
            message

        this.errorTarget.hidden = false

        this.oldVersionTarget?.setAttribute(
            "aria-invalid",
            "true"
        )

        this.newVersionTarget?.setAttribute(
            "aria-invalid",
            "true"
        )
    }

    clearError() {
        if (this.hasErrorTarget) {
            this.errorTarget.textContent = ""
            this.errorTarget.hidden = true
        }

        this.oldVersionTarget?.removeAttribute(
            "aria-invalid"
        )

        this.newVersionTarget?.removeAttribute(
            "aria-invalid"
        )
    }

    setStatus(message, state) {
        if (!this.hasStatusTarget) {
            return
        }

        this.statusTarget.textContent =
            message

        this.statusTarget.dataset.state =
            state
    }
}