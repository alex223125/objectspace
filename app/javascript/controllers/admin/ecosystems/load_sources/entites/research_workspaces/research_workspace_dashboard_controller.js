
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["search", "form", "clear", "status", "results", "count"]
    static values = {
        debounce: { type: Number, default: 300 }
    }

    connect() {
        this.timeout = null
        this.abortController = null
    }

    disconnect() {
        this.cancelPendingSearch()
        this.abortController?.abort()
    }

    search() {
        this.cancelPendingSearch()

        this.timeout = setTimeout(() => {
            this.submitSearch()
        }, this.debounceValue)
    }

    submitSearch() {
        if (!this.hasFormTarget) return

        if (this.hasResultsTarget) {
            this.resultsTarget.setAttribute("aria-busy", "true")
        }

        this.formTarget.requestSubmit()
    }

    clearSearch(event) {
        event?.preventDefault()

        if (!this.hasSearchTarget) return

        this.searchTarget.value = ""

        if (this.hasClearTarget) {
            this.clearTarget.hidden = true
        }

        this.submitSearch()
    }

    updateClearButton() {
        if (!this.hasSearchTarget || !this.hasClearTarget) return

        this.clearTarget.hidden = this.searchTarget.value.trim().length === 0
    }

    filterStatus(event) {
        const status = event.currentTarget.dataset.status || ""
        const url = new URL(window.location.href)

        if (status) {
            url.searchParams.set("status", status)
        } else {
            url.searchParams.delete("status")
        }

        url.searchParams.delete("page")
        window.location.assign(url.toString())
    }

    cancelPendingSearch() {
        if (this.timeout) {
            clearTimeout(this.timeout)
            this.timeout = null
        }
    }
}