import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.oldVersionSelect = this.element.querySelector(
            "[data-version-old-select]"
        )

        this.newVersionSelect = this.element.querySelector(
            "[data-version-new-select]"
        )

        this.versionForm = this.element.querySelector(
            "[data-version-selection-form]"
        )

        this.clientVersionError = this.element.querySelector(
            "[data-version-selection-client-error]"
        )

        this.searchInput = this.element.querySelector(
            "[data-comparison-search]"
        )

        this.typeFilter = this.element.querySelector(
            "[data-comparison-type-filter]"
        )

        this.rowsContainer = this.element.querySelector(
            "[data-comparison-rows]"
        )

        this.emptyState = this.element.querySelector(
            "[data-comparison-empty]"
        )

        this.noFactsState = this.element.querySelector(
            "[data-comparison-no-facts]"
        )

        this.visibleCount = this.element.querySelector(
            "[data-comparison-visible-count]"
        )

        this.rows = this.rowsContainer
            ? Array.from(
                this.rowsContainer.querySelectorAll(
                    "[data-comparison-row]"
                )
            )
            : []

        this.applyFilters()
        this.validateVersionSelection()
    }

    // ============================================================
    // VERSION SELECTION
    // ============================================================

    versionChanged() {
        this.validateVersionSelection()
    }

    submitVersionSelection(event) {
        if (!this.oldVersionSelect || !this.newVersionSelect) {
            return
        }

        const oldVersion = this.oldVersionSelect.value
        const newVersion = this.newVersionSelect.value

        if (!oldVersion || !newVersion) {
            event.preventDefault()

            this.showVersionError(
                "Please select both an old version and a new version."
            )

            return
        }

        if (oldVersion === newVersion) {
            event.preventDefault()

            this.showVersionError(
                "Old version and new version must be different."
            )

            return
        }

        this.hideVersionError()
    }

    resetVersionSelection(event) {
        if (event) {
            event.preventDefault()
        }

        if (!this.versionForm) {
            return
        }

        if (this.oldVersionSelect) {
            this.oldVersionSelect.selectedIndex = 0
        }

        if (this.newVersionSelect) {
            this.newVersionSelect.selectedIndex =
                Math.max(
                    0,
                    this.newVersionSelect.options.length - 1
                )
        }

        this.hideVersionError()

        this.versionForm.submit()
    }

    validateVersionSelection() {
        if (!this.oldVersionSelect || !this.newVersionSelect) {
            return true
        }

        const oldVersion = this.oldVersionSelect.value
        const newVersion = this.newVersionSelect.value

        if (!oldVersion || !newVersion) {
            return false
        }

        if (oldVersion === newVersion) {
            this.showVersionError(
                "Old version and new version must be different."
            )

            return false
        }

        this.hideVersionError()

        return true
    }

    showVersionError(message) {
        if (!this.clientVersionError) {
            return
        }

        this.clientVersionError.textContent = message
        this.clientVersionError.hidden = false

        if (this.oldVersionSelect) {
            this.oldVersionSelect.setAttribute(
                "aria-invalid",
                "true"
            )
        }

        if (this.newVersionSelect) {
            this.newVersionSelect.setAttribute(
                "aria-invalid",
                "true"
            )
        }
    }

    hideVersionError() {
        if (this.clientVersionError) {
            this.clientVersionError.hidden = true
            this.clientVersionError.textContent = ""
        }

        if (this.oldVersionSelect) {
            this.oldVersionSelect.removeAttribute(
                "aria-invalid"
            )
        }

        if (this.newVersionSelect) {
            this.newVersionSelect.removeAttribute(
                "aria-invalid"
            )
        }
    }

    // ============================================================
    // COMPARISON FILTERING
    // ============================================================

    filterChanged() {
        this.applyFilters()
    }

    applyFilters() {
        if (!this.rows.length) {
            this.updateVisibleCount(0)
            this.updateEmptyState(0)

            return
        }

        const searchTerm = this.normalizedSearchTerm()
        const selectedType = this.selectedType()

        let visibleCount = 0

        this.rows.forEach((row) => {
            const matchesSearch =
                this.rowMatchesSearch(
                    row,
                    searchTerm
                )

            const matchesType =
                this.rowMatchesType(
                    row,
                    selectedType
                )

            const visible =
                matchesSearch &&
                matchesType

            row.hidden = !visible

            if (visible) {
                visibleCount += 1
            }
        })

        this.updateVisibleCount(visibleCount)
        this.updateEmptyState(visibleCount)
    }

    normalizedSearchTerm() {
        if (!this.searchInput) {
            return ""
        }

        return this.searchInput.value
            .trim()
            .toLowerCase()
    }

    selectedType() {
        if (!this.typeFilter) {
            return "all"
        }

        return this.typeFilter.value || "all"
    }

    rowMatchesSearch(row, searchTerm) {
        if (!searchTerm) {
            return true
        }

        const searchableText = [
            row.dataset.comparisonPath || "",
            row.dataset.comparisonIdentity || "",
            row.dataset.oldValue || "",
            row.dataset.newValue || "",
            row.dataset.changeType || "",
            row.textContent || ""
        ]
            .join(" ")
            .toLowerCase()

        return searchableText.includes(searchTerm)
    }

    rowMatchesType(row, selectedType) {
        if (!selectedType || selectedType === "all") {
            return true
        }

        return (
            row.dataset.changeType === selectedType
        )
    }

    updateVisibleCount(count) {
        if (!this.visibleCount) {
            return
        }

        this.visibleCount.textContent =
            count.toString()
    }

    updateEmptyState(visibleCount) {
        if (!this.emptyState) {
            return
        }

        const hasRows = this.rows.length > 0

        if (!hasRows) {
            this.emptyState.hidden = true

            if (this.noFactsState) {
                this.noFactsState.hidden = false
            }

            return
        }

        if (this.noFactsState) {
            this.noFactsState.hidden = true
        }

        this.emptyState.hidden =
            visibleCount !== 0
    }

    resetFilters(event) {
        if (event) {
            event.preventDefault()
        }

        if (this.searchInput) {
            this.searchInput.value = ""
        }

        if (this.typeFilter) {
            this.typeFilter.value = "all"
        }

        this.applyFilters()
    }
}