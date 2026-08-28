import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search",
        "sort",
        "spinner",
        "results"
    ]

    static values = {
        searchUrl: String
    }

    connect() {
        this.searchTimeout = null
    }

    disconnect() {
        clearTimeout(this.searchTimeout)
    }

    search() {
        clearTimeout(this.searchTimeout)

        this.showSpinner()

        this.searchTimeout = setTimeout(() => {
            this.loadResults()
        }, 350)
    }

    sort() {
        this.showSpinner()
        this.loadResults()
    }

    loadResults() {
        if (!this.hasResultsTarget) {
            console.error("admin_entity_types: results target is missing")
            this.hideSpinner()
            return
        }

        const params = new URLSearchParams()

        if (this.hasSearchTarget && this.searchTarget.value.trim() !== "") {
            params.set("q", this.searchTarget.value.trim())
        }

        if (this.hasSortTarget && this.sortTarget.value !== "") {
            params.set("sort", this.sortTarget.value)
        }

        const url = `${this.searchUrlValue}?${params.toString()}`

        const frame = document.getElementById("entity_types_results")

        if (!frame) {
            console.error(
                "admin_entity_types: entity_types_results frame is missing"
            )

            this.hideSpinner()
            return
        }

        frame.src = url

        frame.addEventListener(
            "turbo:frame-load",
            () => {
                this.hideSpinner()
            },
            { once: true }
        )

        frame.addEventListener(
            "turbo:frame-missing",
            () => {
                console.error(
                    "admin_entity_types: server response did not contain entity_types_results frame"
                )

                this.hideSpinner()
            },
            { once: true }
        )
    }

    showSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.remove("hidden")
        }
    }

    hideSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.add("hidden")
        }
    }
}
