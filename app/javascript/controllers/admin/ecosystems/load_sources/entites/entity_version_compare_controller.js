import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "row",
    "search",
    "empty",
    "counter",
    "filterButton"
  ]

  connect() {
    this.currentFilter = "all"
    this.refresh()
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  filter(event) {
    event.preventDefault()

    this.currentFilter =
      event.currentTarget.dataset.filter || "all"

    this.filterButtonTargets.forEach((button) => {
      const active =
        button.dataset.filter === this.currentFilter

      button.classList.toggle(
        "bg-slate-900",
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
        "text-slate-600",
        !active
      )
    })

    this.refresh()
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  search() {
    this.refresh()
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  refresh() {
    const query =
      this.hasSearchTarget
        ? this.searchTarget.value
            .trim()
            .toLowerCase()
        : ""

    let visible = 0

    this.rowTargets.forEach((row) => {
      const type =
        row.dataset.changeType

      const path =
        row.dataset.path?.toLowerCase() || ""

      const oldValue =
        row.dataset.oldValue?.toLowerCase() || ""

      const newValue =
        row.dataset.newValue?.toLowerCase() || ""

      const matchesFilter =
        this.currentFilter === "all" ||
        type === this.currentFilter

      const matchesSearch =
        query.length === 0 ||
        path.includes(query) ||
        oldValue.includes(query) ||
        newValue.includes(query)

      const show =
        matchesFilter &&
        matchesSearch

      row.classList.toggle(
        "hidden",
        !show
      )

      if (show) {
        visible += 1
      }
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent =
        `${visible} visible`
    }

    if (this.hasEmptyTarget) {
      this.emptyTarget.classList.toggle(
        "hidden",
        visible > 0
      )
    }
  }

  // ==========================================================
  // EXPAND / COLLAPSE
  // ==========================================================

  toggleDetails(event) {
    const button =
      event.currentTarget

    const targetId =
      button.dataset.target

    const target =
      document.getElementById(targetId)

    if (!target) return

    const expanded =
      button.getAttribute("aria-expanded") === "true"

    button.setAttribute(
      "aria-expanded",
      (!expanded).toString()
    )

    target.classList.toggle(
      "hidden",
      expanded
    )

    const icon =
      button.querySelector(
        "[data-expand-icon]"
      )

    if (icon) {
      icon.textContent =
        expanded ? "+" : "−"
    }
  }

  // ==========================================================
  // COPY VALUE
  // ==========================================================

  async copy(event) {
    event.preventDefault()

    const value =
      event.currentTarget.dataset.copyValue || ""

    try {
      await navigator.clipboard.writeText(
        value
      )

      const button =
        event.currentTarget

      const original =
        button.textContent

      button.textContent =
        "Copied"

      setTimeout(() => {
        button.textContent =
          original
      }, 1200)

    } catch (_) {
      // Clipboard may be unavailable.
    }
  }

  // ==========================================================
  // RESET
  // ==========================================================

  reset() {
    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    this.currentFilter = "all"

    this.filterButtonTargets.forEach(
      (button) => {
        const active =
          button.dataset.filter === "all"

        button.classList.toggle(
          "bg-slate-900",
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
          "text-slate-600",
          !active
        )
      }
    )

    this.refresh()
  }
}