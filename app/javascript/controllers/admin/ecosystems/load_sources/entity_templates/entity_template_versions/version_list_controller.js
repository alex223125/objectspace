import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "list",
        "row",
        "checkbox",
        "selectionBar",
        "selectionCount",
        "compareButton",
        "loadedCount",
        "loadMoreContainer",
        "loading",
        "filterForm",
        "search"
    ]

    connect() {
        this.loadingMore = false
        this.searchTimer = null

        this.refreshSelectionUI()
    }


    disconnect() {
        if (this.searchTimer) {
            clearTimeout(this.searchTimer)
        }
    }


    // ============================================================
    // SEARCH
    // ============================================================

    searchInput() {
        if (this.searchTimer) {
            clearTimeout(this.searchTimer)
        }

        this.searchTimer = setTimeout(() => {
            this.submitFilters()
        }, 350)
    }


    // ============================================================
    // FILTERS
    // ============================================================

    submitFilters() {
        const form = this.filterFormTarget

        const url = new URL(
            form.action,
            window.location.origin
        )

        const formData = new FormData(form)

        for (const [key, value] of formData.entries()) {
            if (value !== "") {
                url.searchParams.set(key, value)
            } else {
                url.searchParams.delete(key)
            }
        }

        url.searchParams.set("page", "1")

        window.Turbo.visit(url.toString())
    }


    // ============================================================
    // LOAD MORE
    // ============================================================

    async loadMore() {
        if (this.loadingMore) {
            return
        }

        const container =
            this.loadMoreContainerTarget

        const button =
            container.querySelector("button")

        if (!button) {
            return
        }

        const currentUrl =
            new URL(window.location.href)

        const currentPage =
            parseInt(
                currentUrl.searchParams.get("page") || "1",
                10
            )

        const nextPage =
            currentPage + 1

        currentUrl.searchParams.set(
            "page",
            nextPage.toString()
        )

        currentUrl.searchParams.set(
            "append",
            "true"
        )


        this.loadingMore = true

        button.disabled = true

        this.loadingTarget.classList.remove("hidden")

        container.classList.add("hidden")


        try {
            const response =
                await fetch(
                    currentUrl.toString(),
                    {
                        headers: {
                            "Accept": "text/html",
                            "Turbo-Frame": "version-list"
                        },
                        credentials: "same-origin"
                    }
                )

            if (!response.ok) {
                throw new Error(
                    `Request failed: ${response.status}`
                )
            }

            const html =
                await response.text()


            if (html.trim() !== "") {

                this.listTarget.insertAdjacentHTML(
                    "beforeend",
                    html
                )

            }


            window.history.replaceState(
                {},
                "",
                this.removeAppendParameter(
                    currentUrl
                )
            )


            this.updateLoadedCount()

            this.refreshSelectionUI()


            // ----------------------------------------------------------
            // Determine whether more records exist.
            //
            // The server returns an empty response when the requested
            // page no longer contains records.
            // ----------------------------------------------------------

            if (html.trim() === "") {

                container.remove()

                this.showFinishedMessage()

            } else {

                container.classList.remove("hidden")

            }

        } catch (error) {

            console.error(
                "Unable to load more versions:",
                error
            )

            container.classList.remove("hidden")

            button.disabled = false

            button.textContent =
                "Retry loading records"

        } finally {

            this.loadingMore = false

            this.loadingTarget.classList.add(
                "hidden"
            )

            button.disabled = false

        }
    }


    // ============================================================
    // SELECTION
    // ============================================================

    selectionChanged() {
        this.refreshSelectionUI()
    }


    refreshSelectionUI() {
        if (!this.hasCheckboxTarget) {
            return
        }

        const selected =
            this.checkboxTargets.filter(
                checkbox => checkbox.checked
            )

        const count =
            selected.length


        if (this.hasSelectionCountTarget) {

            this.selectionCountTarget.textContent =
                `${count} selected`

        }


        if (this.hasSelectionBarTarget) {

            if (count > 0) {
                this.selectionBarTarget.classList.remove(
                    "hidden"
                )
            } else {
                this.selectionBarTarget.classList.add(
                    "hidden"
                )
            }

        }


        if (this.hasCompareButtonTarget) {

            const canCompare =
                count === 2

            this.compareButtonTarget.disabled =
                !canCompare

            this.compareButtonTarget.classList.toggle(
                "opacity-50",
                !canCompare
            )

        }
    }


    // ============================================================
    // CLEAR SELECTION
    // ============================================================

    clearSelection() {
        this.checkboxTargets.forEach(
            checkbox => {
                checkbox.checked = false
            }
        )

        this.refreshSelectionUI()
    }


    // ============================================================
    // COMPARE
    // ============================================================

    compareSelected() {
        const selected =
            this.checkboxTargets
                .filter(checkbox => checkbox.checked)
                .map(checkbox => checkbox.value)

        if (selected.length !== 2) {
            return
        }

        const url =
            `/admin/ecosystems/load_sources/entity_templates/entity_template_versions/${selected[1]}/compare`

        const params =
            new URLSearchParams({
                left_id: selected[0],
                right_id: selected[1]
            })

        window.location.href =
            `${url}?${params.toString()}`
    }


    // ============================================================
    // COUNT
    // ============================================================

    updateLoadedCount() {
        if (!this.hasLoadedCountTarget) {
            return
        }

        const count =
            this.rowTargets.length

        this.loadedCountTarget.textContent =
            count.toString()
    }


    // ============================================================
    // FINISHED
    // ============================================================

    showFinishedMessage() {
        const element =
            document.createElement("div")

        element.className =
            "py-8 text-center"

        element.innerHTML =
            `
        <div class="text-xs font-semibold text-gray-400">
          ✓ All currently available records loaded
        </div>
      `

        this.listTarget.insertAdjacentElement(
            "afterend",
            element
        )
    }


    // ============================================================
    // URL
    // ============================================================

    removeAppendParameter(url) {
        const clean =
            new URL(url.toString())

        clean.searchParams.delete(
            "append"
        )

        return clean.toString()
    }
}
