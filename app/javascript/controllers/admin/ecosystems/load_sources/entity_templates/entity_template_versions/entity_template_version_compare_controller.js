import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "field",
        "search",
        "filter",
        "count",
        "rawLeft",
        "rawRight"
    ]

    connect() {
        this.currentFilter = "all"
        this.currentSearch = ""

        this.applyFilters()
    }

    // ============================================================
    // SEARCH
    // ============================================================

    searchChanged() {
        this.currentSearch =
            this.searchTarget.value
                .trim()
                .toLowerCase()

        this.applyFilters()
    }


    // ============================================================
    // FILTER
    // ============================================================

    filterChanged(event) {
        this.currentFilter =
            event.currentTarget.dataset.filter

        this.updateFilterButtons()
        this.applyFilters()
    }


    // ============================================================
    // APPLY FILTERS
    // ============================================================

    applyFilters() {

        let visible = 0


        this.fieldTargets.forEach((field) => {

            const type =
                field.dataset.changeType || "unchanged"

            const name =
                field.dataset.fieldName || ""


            const matchesFilter =
                this.currentFilter === "all" ||
                type === this.currentFilter


            const matchesSearch =
                this.currentSearch === "" ||
                name.includes(this.currentSearch) ||
                field.innerText
                    .toLowerCase()
                    .includes(this.currentSearch)


            const show =
                matchesFilter &&
                matchesSearch


            field.classList.toggle(
                "hidden",
                !show
            )


            if (show) {
                visible += 1
            }

        })


        this.updateCount(
            visible
        )

    }


    // ============================================================
    // COUNT
    // ============================================================

    updateCount(count) {

        if (!this.hasCountTarget) {
            return
        }


        this.countTarget.textContent =
            `${count} field${count === 1 ? "" : "s"}`

    }


    // ============================================================
    // FILTER BUTTONS
    // ============================================================

    updateFilterButtons() {

        this.filterTargets.forEach((button) => {

            const active =
                button.dataset.filter ===
                this.currentFilter


            button.classList.toggle(
                "bg-gray-900",
                active
            )

            button.classList.toggle(
                "text-white",
                active
            )

            button.classList.toggle(
                "bg-white",
                !active
            )

            button.classList.toggle(
                "text-gray-700",
                !active
            )

        })

    }


    // ============================================================
    // EXPAND / COLLAPSE
    // ============================================================

    toggle(event) {

        const button =
            event.currentTarget

        const targetId =
            button.dataset.target

        if (!targetId) {
            return
        }


        const element =
            document.getElementById(
                targetId
            )

        if (!element) {
            return
        }


        element.classList.toggle(
            "hidden"
        )


        const expanded =
            !element.classList.contains(
                "hidden"
            )


        button.setAttribute(
            "aria-expanded",
            expanded
        )


        const icon =
            button.querySelector(
                "[data-chevron]"
            )


        if (icon) {

            icon.classList.toggle(
                "rotate-180",
                expanded
            )

        }

    }


    // ============================================================
    // EXPAND ALL
    // ============================================================

    expandAll() {

        document
            .querySelectorAll(
                "[data-compare-details]"
            )
            .forEach((element) => {

                element.classList.remove(
                    "hidden"
                )

            })

    }


    // ============================================================
    // COLLAPSE ALL
    // ============================================================

    collapseAll() {

        document
            .querySelectorAll(
                "[data-compare-details]"
            )
            .forEach((element) => {

                element.classList.add(
                    "hidden"
                )

            })

    }


    // ============================================================
    // COPY
    // ============================================================

    async copy(event) {

        const button =
            event.currentTarget

        const targetId =
            button.dataset.copyTarget

        const element =
            document.getElementById(
                targetId
            )


        if (!element) {
            return
        }


        try {

            await navigator.clipboard.writeText(
                element.textContent
            )


            const original =
                button.innerHTML


            button.innerHTML =
                "✓ Copied"


            setTimeout(() => {

                button.innerHTML =
                    original

            }, 1200)


        } catch (error) {

            console.error(
                "Unable to copy definition",
                error
            )

        }

    }

}