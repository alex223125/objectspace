import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "results",
        "spinner",
        "message",
        "toast"
    ]

    static values = {
        searchUrl: String
    }

    connect() {
        this.searchTimer = null
        this.abortController = null

        // Intercept normal links/forms inside this controller.
        this.element.addEventListener("click", this.handleClick.bind(this))
        this.element.addEventListener("submit", this.handleSubmit.bind(this))
    }

    disconnect() {
        this.clearSearchTimer()

        if (this.abortController) {
            this.abortController.abort()
        }
    }

    async handleClick(event) {
        const link = event.target.closest("a[data-async]")

        if (!link) {
            return
        }

        event.preventDefault()

        await this.loadPage(link.href)
    }

    async handleSubmit(event) {
        const form = event.target.closest("form[data-async]")

        if (!form) {
            return
        }

        event.preventDefault()

        await this.submitForm(form)
    }

    async loadPage(url) {
        this.showLoading()
        this.showMessage("Loading template workspace…")

        try {
            const response = await fetch(url, {
                headers: {
                    "Accept": "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })

            if (!response.ok) {
                throw new Error(`Request failed: ${response.status}`)
            }

            const html = await response.text()

            this.resultsTarget.innerHTML = html

            this.showMessage("Workspace loaded.")
            this.showSuccess("✨ Workspace loaded!")

            this.playSuccessAnimation()

            window.history.pushState({}, "", url)
        } catch (error) {
            console.error(error)

            this.showMessage("Unable to load workspace.")
            this.showToast("❌ Something went wrong.")
        } finally {
            this.hideLoading()
        }
    }

    async submitForm(form) {
        this.showLoading()
        this.showMessage("Creating entity template…")

        const formData = new FormData(form)

        try {
            const response = await fetch(form.action, {
                method: form.method.toUpperCase() || "POST",
                body: formData,
                headers: {
                    "Accept": "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })

            if (!response.ok) {
                throw new Error(`Create failed: ${response.status}`)
            }

            const html = await response.text()

            this.resultsTarget.innerHTML = html

            this.showMessage("Entity template created!")
            this.showSuccess("🏆 Template created!")

            this.playSuccessAnimation()

            // If the server redirects, fetch() follows it automatically.
            window.history.pushState({}, "", response.url)
        } catch (error) {
            console.error(error)

            this.showMessage("Unable to create template.")
            this.showToast("❌ Template creation failed.")
        } finally {
            this.hideLoading()
        }
    }

    async search(event) {
        const query = event.target.value

        this.clearSearchTimer()

        this.searchTimer = setTimeout(() => {
            this.performSearch(query)
        }, 350)
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

        this.showLoading()
        this.showMessage("Searching templates…")

        try {
            const response = await fetch(url, {
                headers: {
                    "Accept": "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })

            if (!response.ok) {
                throw new Error(`Search failed: ${response.status}`)
            }

            const html = await response.text()

            const parser = new DOMParser()
            const doc = parser.parseFromString(html, "text/html")

            const results =
                doc.querySelector('[data-async-results]')

            if (results) {
                this.resultsTarget.innerHTML = results.innerHTML
            } else {
                this.resultsTarget.innerHTML = html
            }

            this.showMessage("Search completed.")
            this.showSuccess("✨ Results updated!")

            window.history.replaceState({}, "", url)
        } catch (error) {
            console.error(error)

            this.showToast("❌ Search failed.")
        } finally {
            this.hideLoading()
        }
    }

    filterChanged() {
        const form = this.element.querySelector("form")

        if (!form) {
            return
        }

        this.performSearch(
            form.querySelector('[name="q"]')?.value || ""
        )
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

    showSuccess(message) {
        this.showToast(message)
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
        }, 2500)
    }

    playSuccessAnimation() {
        this.resultsTarget.classList.remove(
            "ring-2",
            "ring-green-400",
            "scale-[1.01]"
        )

        void this.resultsTarget.offsetWidth

        this.resultsTarget.classList.add(
            "ring-2",
            "ring-green-400",
            "scale-[1.01]"
        )

        setTimeout(() => {
            this.resultsTarget.classList.remove(
                "ring-2",
                "ring-green-400",
                "scale-[1.01]"
            )
        }, 700)
    }

    clearSearchTimer() {
        if (this.searchTimer) {
            clearTimeout(this.searchTimer)
            this.searchTimer = null
        }
    }
}