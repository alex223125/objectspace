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
        const frame = document.getElementById("entity_types_results")

        if (!frame) {
            console.error(
                "admin_entity_types: #entity_types_results Turbo Frame not found"
            )

            this.hideSpinner()
            return
        }

        const url = new URL(
            this.searchUrlValue,
            window.location.origin
        )

        if (this.hasSearchTarget) {
            const query = this.searchTarget.value.trim()

            if (query !== "") {
                url.searchParams.set("q", query)
            }
        }

        if (this.hasSortTarget) {
            const sort = this.sortTarget.value

            if (sort !== "") {
                url.searchParams.set("sort", sort)
            }
        }

        const handleLoad = () => {
            this.hideSpinner()
        }

        const handleError = () => {
            this.hideSpinner()
        }

        frame.addEventListener(
            "turbo:frame-load",
            handleLoad,
            { once: true }
        )

        frame.addEventListener(
            "turbo:frame-error",
            handleError,
            { once: true }
        )

        frame.src = url.toString()
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
