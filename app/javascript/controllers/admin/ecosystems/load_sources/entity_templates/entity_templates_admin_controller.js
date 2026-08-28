import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "spinner",
        "message",
        "results",
        "toast"
    ]

    static values = {
        searchUrl: String
    }

    connect() {
        this.searchTimer = null
        this.abortController = null
    }

    disconnect() {
        this.clearSearchTimer()

        if (this.abortController) {
            this.abortController.abort()
        }
    }

    search(event) {
        const query = event.target.value

        this.clearSearchTimer()

        this.searchTimer = setTimeout(() => {
            this.performSearch(query)
        }, 350)
    }

    submitSearch() {
        this.showLoading()

        setTimeout(() => {
            this.showMessage("Loading templates…")
        }, 50)
    }

    filterChanged() {
        const form = this.element.querySelector("form")

        if (!form) {
            return
        }

        this.showLoading()

        form.requestSubmit()
    }

    async performSearch(query) {
        const form = this.element.querySelector("form")

        if (!form) {
            return
        }

        const formData = new FormData(form)
        const params = new URLSearchParams()

        formData.forEach((value, key) => {
            if (value !== "") {
                params.append(key, value)
            }
        })

        params.set("q", query)

        const url = `${this.searchUrlValue}?${params.toString()}`

        if (this.abortController) {
            this.abortController.abort()
        }

        this.abortController = new AbortController()

        this.showLoading()
        this.showMessage("Searching the template knowledge base…")

        try {
            const response = await fetch(url, {
                headers: {
                    Accept: "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                },
                signal: this.abortController.signal
            })

            if (!response.ok) {
                throw new Error(`Search failed: ${response.status}`)
            }

            const html = await response.text()

            this.replaceResults(html)

            this.showMessage(
                query.length > 0
                    ? `New template results loaded for "${query}".`
                    : "Template catalogue loaded."
            )

            this.showToast("✨ New template results loaded")

        } catch (error) {
            if (error.name === "AbortError") {
                return
            }

            console.error(error)

            this.showMessage("Unable to load templates.")

            this.showToast(
                "Something went wrong while loading templates."
            )

        } finally {
            this.hideLoading()
        }
    }

    replaceResults(html) {
        const parser = new DOMParser()

        const document = parser.parseFromString(
            html,
            "text/html"
        )

        const newResults =
            document.querySelector(
                '[data-admin-entity-templates-target="results"]'
            )

        if (!newResults || !this.hasResultsTarget) {
            window.location.href = this.buildCurrentUrl()

            return
        }

        this.resultsTarget.innerHTML = newResults.innerHTML
    }

    buildCurrentUrl() {
        const form = this.element.querySelector("form")

        if (!form) {
            return this.searchUrlValue
        }

        const formData = new FormData(form)
        const params = new URLSearchParams()

        formData.forEach((value, key) => {
            if (value !== "") {
                params.append(key, value)
            }
        })

        return `${this.searchUrlValue}?${params.toString()}`
    }

    showLoading() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.remove("hidden")
        }
    }

    hideLoading() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.add("hidden")
        }
    }

    showMessage(message) {
        if (this.hasMessageTarget) {
            this.messageTarget.textContent = message
        }
    }

    showToast(message) {
        if (!this.hasToastTarget) {
            return
        }

        this.toastTarget.textContent = message
        this.toastTarget.classList.remove("hidden")

        clearTimeout(this.toastTimer)

        this.toastTimer = setTimeout(() => {
            this.toastTarget.classList.add("hidden")
        }, 2200)
    }

    clearSearchTimer() {
        if (this.searchTimer) {
            clearTimeout(this.searchTimer)
            this.searchTimer = null
        }
    }
}
