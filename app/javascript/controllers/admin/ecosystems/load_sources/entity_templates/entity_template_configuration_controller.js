import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search",
        "contextFilter",
        "statusFilter",
        "list",
        "context",
        "template"
    ]

    connect() {
        this.contextData = this.element.dataset.contexts
            ? JSON.parse(this.element.dataset.contexts)
            : []

        this.applyFilter()
    }

    filter() {
        this.applyFilter()
    }

    applyFilter() {
        const query = (this.searchTarget?.value || "")
            .trim()
            .toLowerCase()

        const context = this.contextFilterTarget?.value || ""
        const status = this.statusFilterTarget?.value || ""

        const cards = this.listTarget.querySelectorAll(
            ".configuration-card"
        )

        let visible = 0

        cards.forEach((card) => {
            const searchableText =
                card.dataset.search?.toLowerCase() || ""

            const cardContext =
                card.dataset.context || ""

            const cardStatus =
                card.dataset.status || ""

            const matchesSearch =
                !query ||
                searchableText.includes(query)

            const matchesContext =
                !context ||
                cardContext === context

            const matchesStatus =
                !status ||
                cardStatus === status

            const shouldShow =
                matchesSearch &&
                matchesContext &&
                matchesStatus

            card.classList.toggle(
                "hidden",
                !shouldShow
            )

            if (shouldShow) {
                visible++
            }
        })

        this.updateEmptyState(visible)
    }

    updateEmptyState(visible) {
        let emptyState =
            this.listTarget.querySelector(
                "[data-filter-empty]"
            )

        if (visible > 0) {
            emptyState?.remove()
            return
        }

        if (!emptyState) {
            emptyState = document.createElement("div")

            emptyState.dataset.filterEmpty = "true"

            emptyState.className =
                "md:col-span-2 xl:col-span-3 rounded-3xl " +
                "border border-dashed border-gray-300 bg-white " +
                "p-12 text-center dark:border-gray-700 dark:bg-gray-800"

            emptyState.innerHTML = `
        <div class="mx-auto mb-4 flex h-14 w-14 items-center
                    justify-center rounded-2xl bg-indigo-50 text-2xl">
          🔎
        </div>

        <div class="text-lg font-black text-gray-900 dark:text-white">
          No matching configurations
        </div>

        <div class="mt-2 text-sm text-gray-500">
          Try changing your filters or search term.
        </div>
      `

            this.listTarget.appendChild(emptyState)
        }
    }

    entityTypeChanged(event) {
        const entityTypeId = event.target.value

        if (!entityTypeId || !this.templateTarget) {
            return
        }

        Array.from(this.templateTarget.options).forEach((option) => {
            if (!option.value) return

            const entityType =
                option.dataset.entityType

            option.hidden =
                entityType &&
                entityType !== entityTypeId
        })

        this.templateTarget.value = ""
    }

    contextTypeChanged(event) {
        const contextType = event.target.value

        if (!this.contextTarget) {
            return
        }

        this.contextTarget.innerHTML = ""

        const placeholder =
            document.createElement("option")

        placeholder.value = ""
        placeholder.textContent =
            contextType
                ? `Choose ${this.humanize(contextType)}`
                : "Choose target"

        this.contextTarget.appendChild(
            placeholder
        )

        if (!contextType) {
            return
        }

        const matchingContexts =
            this.contextData.filter(
                (context) =>
                    context.type === contextType
            )

        matchingContexts.forEach((context) => {
            const option =
                document.createElement("option")

            option.value = context.id
            option.textContent = context.name

            this.contextTarget.appendChild(option)
        })
    }

    humanize(value) {
        return value
            .replace(/([A-Z])/g, " $1")
            .trim()
    }
}
