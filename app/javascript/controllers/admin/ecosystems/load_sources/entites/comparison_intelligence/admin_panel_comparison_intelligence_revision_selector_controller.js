
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["select", "summary", "form"]
    static values = {
        url: String,
        autoSubmit: { type: Boolean, default: false }
    }

    connect() {
        this.updateSummary()
    }

    change() {
        this.updateSummary()

        if (this.hasFormTarget && this.autoSubmitValue) {
            this.formTarget.requestSubmit()
        }
    }

    updateSummary() {
        if (!this.hasSummaryTarget || !this.hasSelectTarget) return

        const option = this.selectTarget.selectedOptions[0]
        this.summaryTarget.textContent = option
            ? `Selected revision: ${option.textContent.trim()}`
            : "Select a revision to continue."
    }

    selectLatest(event) {
        event?.preventDefault()
        if (!this.hasSelectTarget) return

        const options = Array.from(this.selectTarget.options)
            .filter(option => !option.disabled && option.value !== "")

        if (!options.length) return

        this.selectTarget.selectedIndex =
            this.selectTarget.options.length - options.length

        this.selectTarget.dispatchEvent(
            new Event("change", { bubbles: true })
        )

        this.change()
    }

    submit(event) {
        if (!this.hasSelectTarget || this.selectTarget.value) return

        event.preventDefault()
        this.selectTarget.focus()
        this.selectTarget.setCustomValidity("Choose a revision first.")
        this.selectTarget.reportValidity()
        this.selectTarget.addEventListener(
            "change",
            () => this.selectTarget.setCustomValidity(""),
            { once: true }
        )
    }
}