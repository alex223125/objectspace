import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "input",
        "results",
        "selected",
        "selectedName",
        "selectedMeta",
        "selectedId",
        "createButton",
        "status",
        "loading",
        "empty",
        "clearButton"
    ]

    static values = {
        searchUrl: String,
        createUrl: String,
        debounce: {
            type: Number,
            default: 300
        },
        minimumCharacters: {
            type: Number,
            default: 1
        }
    }

    connect() {
        this.timer = null
        this.abortController = null
        this.highlightedIndex = -1
        this.resultsData = []

        this.closeResults()

        this.updateCreateButton()
    }

    disconnect() {
        this.clearTimer()
        this.abortRequest()
    }

    // ============================================================
    // SEARCH
    // ============================================================

    inputChanged() {
        const query = this.inputTarget.value.trim()

        this.clearTimer()
        this.highlightedIndex = -1

        if (query.length < this.minimumCharactersValue) {
            this.clearResults()
            this.closeResults()
            this.hideLoading()

            return
        }

        this.timer = window.setTimeout(() => {
            this.search(query)
        }, this.debounceValue)
    }

    async search(query) {
        this.abortRequest()

        this.abortController = new AbortController()

        this.showLoading()
        this.openResults()

        try {
            const url = new URL(
                this.searchUrlValue,
                window.location.origin
            )

            url.searchParams.set("q", query)

            const response = await fetch(url.toString(), {
                method: "GET",
                headers: {
                    "Accept": "application/json",
                    "X-Requested-With": "XMLHttpRequest"
                },
                credentials: "same-origin",
                signal: this.abortController.signal
            })

            if (!response.ok) {
                throw new Error(
                    `Template search failed with HTTP ${response.status}`
                )
            }

            const data = await response.json()

            this.resultsData = Array.isArray(data.results)
                ? data.results
                : []

            this.renderResults()

        } catch (error) {
            if (error.name === "AbortError") {
                return
            }

            console.error(
                "[EntityTemplateVersionCreator]",
                error
            )

            this.resultsData = []

            this.renderError(
                "Unable to search entity templates. Please try again."
            )

        } finally {
            this.hideLoading()
            this.abortController = null
        }
    }

    // ============================================================
    // RESULT RENDERING
    // ============================================================

    renderResults() {
        this.resultsTarget.innerHTML = ""

        if (this.resultsData.length === 0) {
            this.showEmpty()

            return
        }

        this.hideEmpty()

        this.resultsData.forEach((template, index) => {
            const button = document.createElement("button")

            button.type = "button"

            button.className = [
                "group",
                "flex",
                "w-full",
                "items-start",
                "gap-3",
                "border-b",
                "border-gray-100",
                "px-4",
                "py-3",
                "text-left",
                "transition",
                "last:border-b-0",
                "hover:bg-violet-50",
                "dark:border-gray-700",
                "dark:hover:bg-violet-950/20"
            ].join(" ")

            button.dataset.index = index

            button.addEventListener("mouseenter", () => {
                this.highlightedIndex = index
                this.refreshHighlight()
            })

            button.addEventListener("click", () => {
                this.selectTemplate(template)
            })

            const icon = document.createElement("div")

            icon.className = [
                "flex",
                "h-9",
                "w-9",
                "shrink-0",
                "items-center",
                "justify-center",
                "rounded-lg",
                "bg-violet-100",
                "text-violet-600",
                "dark:bg-violet-900/30",
                "dark:text-violet-300"
            ].join(" ")

            icon.textContent = "🧬"

            const content = document.createElement("div")

            content.className = "min-w-0 flex-1"

            const name = document.createElement("div")

            name.className = [
                "truncate",
                "text-sm",
                "font-bold",
                "text-gray-900",
                "group-hover:text-violet-700",
                "dark:text-white",
                "dark:group-hover:text-violet-300"
            ].join(" ")

            name.textContent =
                template.name ||
                template.title ||
                `Entity Template #${template.id}`

            const meta = document.createElement("div")

            meta.className = [
                "mt-1",
                "flex",
                "flex-wrap",
                "items-center",
                "gap-x-2",
                "gap-y-1",
                "font-mono",
                "text-[10px]",
                "text-gray-400"
            ].join(" ")

            const id = document.createElement("span")

            id.textContent = `ID: ${template.id}`

            meta.appendChild(id)

            if (template.slug) {
                const separator = document.createElement("span")
                separator.textContent = "·"

                const slug = document.createElement("span")
                slug.textContent = template.slug

                meta.appendChild(separator)
                meta.appendChild(slug)
            }

            if (template.title && template.name) {
                const separator = document.createElement("span")
                separator.textContent = "·"

                const title = document.createElement("span")
                title.textContent = template.title

                meta.appendChild(separator)
                meta.appendChild(title)
            }

            content.appendChild(name)
            content.appendChild(meta)

            button.appendChild(icon)
            button.appendChild(content)

            this.resultsTarget.appendChild(button)
        })

        this.openResults()
    }

    renderError(message) {
        this.resultsTarget.innerHTML = ""

        const wrapper = document.createElement("div")

        wrapper.className = [
            "px-4",
            "py-5",
            "text-center"
        ].join(" ")

        const title = document.createElement("div")

        title.className = [
            "text-sm",
            "font-bold",
            "text-red-600",
            "dark:text-red-400"
        ].join(" ")

        title.textContent = message

        wrapper.appendChild(title)

        this.resultsTarget.appendChild(wrapper)

        this.openResults()
    }

    // ============================================================
    // SELECT TEMPLATE
    // ============================================================

    selectTemplate(template) {
        if (!template || !template.id) {
            return
        }

        this.selectedIdTarget.value = template.id

        this.selectedNameTarget.textContent =
            template.name ||
            template.title ||
            `Entity Template #${template.id}`

        const metadata = []

        metadata.push(`ID ${template.id}`)

        if (template.slug) {
            metadata.push(template.slug)
        }

        if (template.title && template.name) {
            metadata.push(template.title)
        }

        this.selectedMetaTarget.textContent =
            metadata.join(" · ")

        this.selectedTarget.classList.remove("hidden")

        this.inputTarget.value =
            template.name ||
            template.title ||
            template.slug ||
            `Entity Template #${template.id}`

        this.clearResults()
        this.closeResults()

        this.updateCreateButton()

        this.setStatus(
            "Template selected. You can now create its next version.",
            "success"
        )
    }

    clearSelection() {
        this.selectedIdTarget.value = ""

        this.selectedTarget.classList.add("hidden")

        this.inputTarget.value = ""

        this.clearResults()
        this.closeResults()

        this.updateCreateButton()

        this.setStatus(
            "Search for an Entity Template to continue.",
            "neutral"
        )

        this.inputTarget.focus()
    }

    // ============================================================
    // CREATE VERSION
    // ============================================================

    createVersion() {
        const templateId =
            this.selectedIdTarget.value

        if (!templateId) {
            this.setStatus(
                "Please select an Entity Template first.",
                "error"
            )

            this.inputTarget.focus()

            return
        }

        const url = new URL(
            this.createUrlValue,
            window.location.origin
        )

        url.searchParams.set(
            "entity_template_id",
            templateId
        )

        window.location.href = url.toString()
    }

    // ============================================================
    // KEYBOARD NAVIGATION
    // ============================================================

    keydown(event) {
        if (event.key === "ArrowDown") {
            event.preventDefault()

            if (!this.resultsData.length) {
                return
            }

            this.highlightedIndex =
                Math.min(
                    this.highlightedIndex + 1,
                    this.resultsData.length - 1
                )

            this.refreshHighlight()

            return
        }

        if (event.key === "ArrowUp") {
            event.preventDefault()

            if (!this.resultsData.length) {
                return
            }

            this.highlightedIndex =
                Math.max(
                    this.highlightedIndex - 1,
                    0
                )

            this.refreshHighlight()

            return
        }

        if (event.key === "Enter") {
            if (
                this.highlightedIndex >= 0 &&
                this.resultsData[this.highlightedIndex]
            ) {
                event.preventDefault()

                this.selectTemplate(
                    this.resultsData[this.highlightedIndex]
                )
            }

            return
        }

        if (event.key === "Escape") {
            this.closeResults()

            return
        }
    }

    refreshHighlight() {
        const buttons =
            this.resultsTarget.querySelectorAll(
                "button[data-index]"
            )

        buttons.forEach((button, index) => {
            if (index === this.highlightedIndex) {
                button.classList.add(
                    "bg-violet-50",
                    "dark:bg-violet-950/30"
                )
            } else {
                button.classList.remove(
                    "bg-violet-50",
                    "dark:bg-violet-950/30"
                )
            }
        })
    }

    // ============================================================
    // OUTSIDE CLICK
    // ============================================================

    clickOutside(event) {
        if (!this.element.contains(event.target)) {
            this.closeResults()
        }
    }

    // ============================================================
    // UI
    // ============================================================

    updateCreateButton() {
        const enabled =
            this.selectedIdTarget.value.trim() !== ""

        this.createButtonTarget.disabled =
            !enabled

        if (enabled) {
            this.createButtonTarget.classList.remove(
                "cursor-not-allowed",
                "opacity-50"
            )
        } else {
            this.createButtonTarget.classList.add(
                "cursor-not-allowed",
                "opacity-50"
            )
        }
    }

    openResults() {
        this.resultsTarget.classList.remove("hidden")
    }

    closeResults() {
        this.resultsTarget.classList.add("hidden")
    }

    clearResults() {
        this.resultsData = []

        this.resultsTarget.innerHTML = ""

        this.hideEmpty()
    }

    showLoading() {
        this.loadingTarget.classList.remove("hidden")
    }

    hideLoading() {
        this.loadingTarget.classList.add("hidden")
    }

    showEmpty() {
        this.emptyTarget.classList.remove("hidden")
    }

    hideEmpty() {
        this.emptyTarget.classList.add("hidden")
    }

    setStatus(message, type = "neutral") {
        this.statusTarget.textContent = message

        this.statusTarget.classList.remove(
            "text-gray-400",
            "text-emerald-600",
            "text-red-600",
            "dark:text-gray-400",
            "dark:text-emerald-400",
            "dark:text-red-400"
        )

        if (type === "success") {
            this.statusTarget.classList.add(
                "text-emerald-600",
                "dark:text-emerald-400"
            )
        } else if (type === "error") {
            this.statusTarget.classList.add(
                "text-red-600",
                "dark:text-red-400"
            )
        } else {
            this.statusTarget.classList.add(
                "text-gray-400",
                "dark:text-gray-400"
            )
        }
    }

    // ============================================================
    // REQUEST MANAGEMENT
    // ============================================================

    clearTimer() {
        if (this.timer) {
            window.clearTimeout(this.timer)
            this.timer = null
        }
    }

    abortRequest() {
        if (this.abortController) {
            this.abortController.abort()
            this.abortController = null
        }
    }
}