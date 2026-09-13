import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search",
        "status",
        "scope",
        "entityType",
        "template",
        "sort",
        "row",
        "selectAll",
        "rowCheckbox",
        "selectionCount",
        "bulkBar",
        "resultsCount",
        "filterForm"
    ]

    connect() {
        this.updateSelectionState()
    }

    // ---------------------------------------------------------
    // LOCAL UI FILTERING
    //
    // Server-side Searchkick filtering remains authoritative.
    // This method is useful for instant UI filtering when the
    // index already contains the rendered rows.
    // ---------------------------------------------------------

    filter() {
        const search = this.hasSearchTarget
            ? this.searchTarget.value.toLowerCase().trim()
            : ""

        const status = this.hasStatusTarget
            ? this.statusTarget.value
            : ""

        const scope = this.hasScopeTarget
            ? this.scopeTarget.value
            : ""

        const entityType = this.hasEntityTypeTarget
            ? this.entityTypeTarget.value
            : ""

        const template = this.hasTemplateTarget
            ? this.templateTarget.value
            : ""

        this.rowTargets.forEach((row) => {
            const rowSearch = (row.dataset.search || "").toLowerCase()
            const rowStatus = row.dataset.status || ""
            const rowScope = row.dataset.scope || ""
            const rowEntityType = row.dataset.entityTypeId || ""
            const rowTemplate = row.dataset.templateId || ""

            const matchesSearch =
                !search || rowSearch.includes(search)

            const matchesStatus =
                !status || rowStatus === status

            const matchesScope =
                !scope || rowScope === scope

            const matchesEntityType =
                !entityType || rowEntityType === entityType

            const matchesTemplate =
                !template || rowTemplate === template

            row.hidden = !(
                matchesSearch &&
                matchesStatus &&
                matchesScope &&
                matchesEntityType &&
                matchesTemplate
            )
        })

        this.updateSelectionState()
    }

    // ---------------------------------------------------------
    // SERVER-SIDE SEARCH
    //
    // Step 11 uses Searchkick/Elasticsearch on the Rails side.
    // Submit the filter form instead of trying to query
    // Elasticsearch directly from the browser.
    // ---------------------------------------------------------

    submitFilters(event) {
        if (event) {
            event.preventDefault()
        }

        if (this.hasFilterFormTarget) {
            this.filterFormTarget.requestSubmit()
            return
        }

        const form = this.element.querySelector("form")

        if (form) {
            form.requestSubmit()
        }
    }

    // ---------------------------------------------------------
    // SORTING
    // ---------------------------------------------------------

    sortBy(event) {
        event.preventDefault()

        const sortValue = event.currentTarget.dataset.sort

        if (!sortValue) {
            return
        }

        if (this.hasSortTarget) {
            this.sortTarget.value = sortValue
        }

        this.submitFilters()
    }

    // ---------------------------------------------------------
    // SELECT ALL
    // ---------------------------------------------------------

    toggleAll() {
        if (!this.hasSelectAllTarget) {
            return
        }

        const checked = this.selectAllTarget.checked

        this.rowTargets.forEach((row) => {
            if (row.hidden) {
                return
            }

            const checkbox = row.querySelector(
                'input[type="checkbox"][data-entity-command-center-target="rowCheckbox"]'
            )

            if (checkbox) {
                checkbox.checked = checked
            }
        })

        this.updateSelectionState()
    }

    // ---------------------------------------------------------
    // INDIVIDUAL SELECTION
    // ---------------------------------------------------------

    updateSelection() {
        this.updateSelectionState()
    }

    updateSelectionState() {
        if (!this.hasRowCheckboxTarget) {
            return
        }

        const checkboxes = this.rowCheckboxTargets

        const visibleCheckboxes = checkboxes.filter((checkbox) => {
            const row = checkbox.closest(
                '[data-entity-command-center-target="row"]'
            )

            return row && !row.hidden
        })

        const selectedCheckboxes = visibleCheckboxes.filter(
            (checkbox) => checkbox.checked
        )

        const selectedCount = selectedCheckboxes.length

        // Selection count
        if (this.hasSelectionCountTarget) {
            this.selectionCountTarget.textContent =
                `${selectedCount} selected`
        }

        // Bulk action bar
        if (this.hasBulkBarTarget) {
            this.bulkBarTarget.classList.toggle(
                "hidden",
                selectedCount === 0
            )
        }

        // Select-all checkbox
        if (this.hasSelectAllTarget) {
            const visibleCount = visibleCheckboxes.length

            this.selectAllTarget.checked =
                visibleCount > 0 &&
                selectedCount === visibleCount

            this.selectAllTarget.indeterminate =
                selectedCount > 0 &&
                selectedCount < visibleCount
        }
    }

    // ---------------------------------------------------------
    // CLEAR FILTERS
    // ---------------------------------------------------------

    clearFilters(event) {
        if (event) {
            event.preventDefault()
        }

        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasStatusTarget) {
            this.statusTarget.value = ""
        }

        if (this.hasScopeTarget) {
            this.scopeTarget.value = ""
        }

        if (this.hasEntityTypeTarget) {
            this.entityTypeTarget.value = ""
        }

        if (this.hasTemplateTarget) {
            this.templateTarget.value = ""
        }

        if (this.hasSortTarget) {
            this.sortTarget.value = "updated"
        }

        this.submitFilters()
    }

    // ---------------------------------------------------------
    // CLEAR SELECTION
    // ---------------------------------------------------------

    clearSelection(event) {
        if (event) {
            event.preventDefault()
        }

        this.rowCheckboxTargets.forEach((checkbox) => {
            checkbox.checked = false
        })

        if (this.hasSelectAllTarget) {
            this.selectAllTarget.checked = false
            this.selectAllTarget.indeterminate = false
        }

        this.updateSelectionState()
    }

    // ---------------------------------------------------------
    // BULK ACTION FOUNDATION
    //
    // Step 11 intentionally does NOT execute destructive
    // actions. These methods only expose selected IDs so that
    // Step 12/Phase C can build the real bulk workflow.
    // ---------------------------------------------------------

    selectedIds() {
        if (!this.hasRowCheckboxTarget) {
            return []
        }

        return this.rowCheckboxTargets
            .filter((checkbox) => checkbox.checked)
            .map((checkbox) => checkbox.value)
            .filter((value) => value)
    }

    prepareBulkAction(event) {
        if (event) {
            event.preventDefault()
        }

        const ids = this.selectedIds()

        if (ids.length === 0) {
            return
        }

        // Foundation only.
        //
        // The selected IDs are intentionally not submitted yet.
        // Step 12 will connect these selections to actual bulk
        // lifecycle operations.
        this.dispatch("bulk-selection-ready", {
            detail: {
                ids: ids,
                count: ids.length
            }
        })
    }

    // ---------------------------------------------------------
    // KEYBOARD SUPPORT
    // ---------------------------------------------------------

    handleKeydown(event) {
        // Cmd/Ctrl + K focuses search.
        if (
            (event.metaKey || event.ctrlKey) &&
            event.key.toLowerCase() === "k"
        ) {
            event.preventDefault()

            if (this.hasSearchTarget) {
                this.searchTarget.focus()
                this.searchTarget.select()
            }
        }

        // Escape clears selection.
        if (event.key === "Escape") {
            this.clearSelection()
        }
    }
}