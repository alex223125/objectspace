import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "articles",
        "sentinel",
        "loading",
        "endMessage",
        "pagination",
        "toast",
        "toastContent",
        "toastIcon",
        "toastSpinner",
        "toastMessage",
        "visibleCount",
        "totalCount",
        "currentPageLabel",
        "totalPagesLabel"
    ]

    static values = {
        currentPage: Number,
        totalPages: Number,
        url: String
    }

    connect() {
        console.log(
            "Algorithm versions admin dashboard infinity scroll connected"
        )

        this.loadingMore = false
        this.observer = null
        this.toastTimer = null

        this.setupIntersectionObserver()
        this.hidePaginationIfPossible()
        this.updateEndState()
    }

    disconnect() {
        console.log(
            "Algorithm versions admin dashboard infinity scroll disconnected"
        )

        this.disconnectObserver()
        this.clearToastTimer()
    }


    // ============================================================
    // INTERSECTION OBSERVER
    // ============================================================

    setupIntersectionObserver() {
        if (!this.hasSentinelTarget) {
            console.warn(
                "Infinity scroll sentinel target was not found"
            )
            return
        }

        this.disconnectObserver()

        // FIX: Replaced "(entries) => { const entry = entries }" with array destructuring
        // This extracts the first Entry object out of the observer batch cleanly.
        this.observer = new IntersectionObserver(
            ([entry]) => {
                if (!entry || !entry.isIntersecting) {
                    return
                }

                this.loadNextPage()
            },
            {
                root: null,
                rootMargin: "0px 0px 700px 0px",
                threshold: 0
            }
        )

        this.observer.observe(this.sentinelTarget)
    }

    disconnectObserver() {
        if (!this.observer) {
            return
        }

        this.observer.disconnect()
        this.observer = null
    }


    // ============================================================
    // LOAD NEXT PAGE
    // ============================================================

    async loadNextPage() {
        if (this.loadingMore) {
            return
        }

        if (!this.hasNextPage()) {
            this.finishInfinityScroll()
            return
        }

        this.loadingMore = true

        const nextPage = this.currentPageValue + 1

        this.showLoadingState()

        this.showToast(
            `Loading articles from page ${nextPage}...`,
            "loading"
        )

        try {
            const url = this.buildPageUrl(nextPage)

            console.log(
                `Loading article versions page ${nextPage}:`,
                url
            )

            const response = await fetch(url, {
                method: "GET",
                headers: {
                    "Accept": "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                },
                credentials: "same-origin"
            })

            if (!response.ok) {
                throw new Error(
                    `HTTP error ${response.status}`
                )
            }

            const html = await response.text()

            if (!html.trim()) {
                this.handleNoMoreResults()
                return
            }

            /*
             * IMPORTANT:
             *
             * The server must return ONLY the <tr> elements
             * for an infinite-scroll request.
             */
            const parser = new DOMParser()
            const documentFragment = parser.parseFromString(
                html,
                "text/html"
            )

            const rows = Array.from(
                documentFragment.querySelectorAll(
                    "tr[data-infinite-scroll-row]"
                )
            )

            if (rows.length === 0) {
                this.handleNoMoreResults()
                return
            }

            this.appendRows(rows)

            this.currentPageValue = nextPage

            this.updatePageLabels()

            this.updateVisibleCount(rows.length)

            this.hideLoadingState()

            this.showToast(
                `${rows.length} ${
                    rows.length === 1 ? "article" : "articles"
                } loaded`,
                "success"
            )

            this.updateEndState()

        } catch (error) {
            console.error(
                "Failed to load more article versions:",
                error
            )

            this.hideLoadingState()

            this.showToast(
                "Unable to load more articles. Please try again.",
                "error"
            )

        } finally {
            this.loadingMore = false
        }
    }


    // ============================================================
    // URL & PAGINATION LOGIC
    // ============================================================

    buildPageUrl(page) {
        const url = new URL(
            this.urlValue,
            window.location.origin
        )

        const currentParams = new URLSearchParams(
            window.location.search
        )

        currentParams.forEach((value, key) => {
            if (key === "page") {
                return
            }
            url.searchParams.set(key, value)
        })

        url.searchParams.set("page", page)

        /*
         * Tell Rails that this request is specifically
         * for the infinite-scroll fragment.
         */
        url.searchParams.set("infinite_scroll", "true")

        return url.toString()
    }

    hasNextPage() {
        return this.currentPageValue < this.totalPagesValue
    }

    handleNoMoreResults() {
        this.currentPageValue = this.totalPagesValue
        this.hideLoadingState()
        this.finishInfinityScroll()
        this.showToast("All articles have been loaded", "success")
    }

    finishInfinityScroll() {
        this.disconnectObserver()
        this.hideLoadingState()

        if (this.hasSentinelTarget) {
            this.sentinelTarget.classList.add("hidden")
        }

        if (this.hasEndMessageTarget) {
            this.endMessageTarget.classList.remove("hidden")
        }
    }


    // ============================================================
    // DOM UPDATES & LABELS
    // ============================================================

    appendRows(rows) {
        const fragment = document.createDocumentFragment()

        rows.forEach((row) => {
            fragment.appendChild(
                document.importNode(row, true)
            )
        })

        this.articlesTarget.appendChild(fragment)
    }

    hidePaginationIfPossible() {
        if (this.hasPaginationTarget) {
            this.paginationTarget.classList.add("hidden")
        }
    }

    updatePageLabels() {
        if (this.hasCurrentPageLabelTarget) {
            this.currentPageLabelTarget.textContent = this.currentPageValue
        }

        if (this.hasTotalPagesLabelTarget) {
            this.totalPagesLabelTarget.textContent = this.totalPagesValue
        }
    }

    updateVisibleCount(numberOfNewRows) {
        if (!this.hasVisibleCountTarget) {
            return
        }

        const current = parseInt(this.visibleCountTarget.textContent, 10) || 0
        this.visibleCountTarget.textContent = current + numberOfNewRows
    }

    updateEndState() {
        if (this.hasNextPage()) {
            if (this.hasEndMessageTarget) {
                this.endMessageTarget.classList.add("hidden")
            }
            return
        }

        this.finishInfinityScroll()
    }


    // ============================================================
    // LOADING UI STATES
    // ============================================================

    showLoadingState() {
        if (this.hasLoadingTarget) {
            this.loadingTarget.classList.remove("hidden")
            // Forces flex re-alignment if you are utilizing flex alignments
            this.loadingTarget.classList.add("flex")
        }

        if (this.hasSentinelTarget) {
            this.sentinelTarget.classList.add("hidden")
        }
    }

    hideLoadingState() {
        if (this.hasLoadingTarget) {
            this.loadingTarget.classList.add("hidden")
            this.loadingTarget.classList.remove("flex")
        }

        if (this.hasSentinelTarget && this.hasNextPage()) {
            this.sentinelTarget.classList.remove("hidden")
        }
    }


    // ============================================================
    // TOAST SYSTEM (Tailwind Theme Integration)
    // ============================================================

    showToast(message, type = "loading") {
        if (!this.hasToastTarget) {
            return
        }

        this.clearToastTimer()

        this.toastMessageTarget.textContent = message

        // Animate state visibility to active frame
        this.toastTarget.classList.remove("-translate-y-5", "opacity-0")
        this.toastTarget.classList.add("translate-y-0", "opacity-100")

        // Thoroughly purge old state utility bounds
        this.toastContentTarget.classList.remove(
            "border-sky-200", "text-sky-600", "dark:border-sky-500/30", "dark:text-sky-400",
            "border-emerald-200", "text-emerald-600", "dark:border-emerald-500/30", "dark:text-emerald-400",
            "border-rose-200", "text-rose-600", "dark:border-rose-500/30", "dark:text-rose-400"
        )

        if (type === "loading") {
            this.toastContentTarget.classList.add(
                "border-sky-200", "text-sky-600", "dark:border-sky-500/30", "dark:text-sky-400"            )

            if (this.hasToastIconTarget) this.toastIconTarget.classList.add("hidden")
            if (this.hasToastSpinnerTarget) this.toastSpinnerTarget.classList.remove("hidden")
            return
        }

        if (type === "success") {
            this.toastContentTarget.classList.add(
                "border-emerald-200", "text-emerald-600", "dark:border-emerald-500/30", "dark:text-emerald-400"
            )

            if (this.hasToastSpinnerTarget) this.toastSpinnerTarget.classList.add("hidden")
            if (this.hasToastIconTarget) {
                this.toastIconTarget.classList.remove("hidden")
                this.toastIconTarget.textContent = "✓"
            }
        }

        if (type === "error") {
            this.toastContentTarget.classList.add(
                "border-rose-200", "text-rose-600", "dark:border-rose-500/30", "dark:text-rose-400"
            )

            if (this.hasToastSpinnerTarget) this.toastSpinnerTarget.classList.add("hidden")
            if (this.hasToastIconTarget) {
                this.toastIconTarget.classList.remove("hidden")
                this.toastIconTarget.textContent = "!"
            }
        }

        this.toastTimer = window.setTimeout(() => {
            this.hideToast()
        }, 2500)
    }

    hideToast() {
        if (!this.hasToastTarget) {
            return
        }

        this.toastTarget.classList.remove("translate-y-0", "opacity-100")
        this.toastTarget.classList.add("-translate-y-5", "opacity-0")
    }

    clearToastTimer() {
        if (!this.toastTimer) {
            return
        }

        window.clearTimeout(this.toastTimer)
        this.toastTimer = null
    }
}

