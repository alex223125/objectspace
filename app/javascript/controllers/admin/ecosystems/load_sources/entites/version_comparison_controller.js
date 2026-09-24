import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "row",
        "search",
        "filter",
        "count",
        "empty",
        "leftPane",
        "rightPane"
    ]

    connect() {
        this.filterRows()
    }

    search() {
        this.filterRows()
    }

    filter() {
        this.filterRows()
    }

    reset() {
        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasFilterTarget) {
            this.filterTarget.value = "all"
        }

        this.filterRows()
    }

    filterRows() {
        const query =
            this.hasSearchTarget
                ? this.searchTarget.value.trim().toLowerCase()
                : ""

        const filter =
            this.hasFilterTarget
                ? this.filterTarget.value
                : "all"

        let visible = 0

        this.rowTargets.forEach((row) => {
            const field =
                (row.dataset.field || "").toLowerCase()

            const status =
                row.dataset.status || ""

            const matchesSearch =
                !query ||
                field.includes(query)

            const matchesFilter =
                filter === "all" ||
                status === filter

            const show =
                matchesSearch &&
                matchesFilter

            row.hidden = !show

            if (show) {
                visible += 1
            }
        })

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visible} field${visible === 1 ? "" : "s"}`
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.hidden =
                visible !== 0
        }
    }

    copy(event) {
        const button =
            event.currentTarget

        const value =
            button.dataset.value || ""

        navigator.clipboard
            .writeText(value)
            .then(() => {
                const original =
                    button.innerHTML

                button.innerHTML = "✓ Copied"

                setTimeout(() => {
                    button.innerHTML = original
                }, 1200)
            })
    }

    expand(event) {
        const targetId =
            event.currentTarget.dataset.target

        const target =
            this.element.querySelector(
                `[data-expand-target="${targetId}"]`
            )

        if (!target) {
            return
        }

        target.hidden =
            !target.hidden

        event.currentTarget.setAttribute(
            "aria-expanded",
            String(!target.hidden)
        )
    }

    syncLeft() {
        if (!this.hasRightPaneTarget) {
            return
        }

        this.rightPaneTarget.scrollTop =
            this.leftPaneTarget.scrollTop
    }

    syncRight() {
        if (!this.hasLeftPaneTarget) {
            return
        }

        this.leftPaneTarget.scrollTop =
            this.rightPaneTarget.scrollTop
    }
}