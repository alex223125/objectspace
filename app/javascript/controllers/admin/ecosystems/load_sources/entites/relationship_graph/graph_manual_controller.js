
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "search",
    "section",
    "empty",
    "status"
  ]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.hasSearchTarget
        ? this.searchTarget.value.trim().toLowerCase()
        : ""

    let visible = 0

    this.sectionTargets.forEach((section) => {
      const searchableText = [
        section.dataset.title,
        section.textContent
      ].filter(Boolean).join(" ").toLowerCase()

      const matches = !query || searchableText.includes(query)

      section.hidden = !matches

      if (matches) visible += 1
    })

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = visible > 0
    }

    this.announce(
        query
            ? `${visible} manual sections match your search.`
            : `${visible} manual sections available.`
    )
  }

  expandAll() {
    this.sectionTargets.forEach((section) => {
      section.open = true
    })

    this.announce("All manual sections expanded.")
  }

  collapseAll() {
    this.sectionTargets.forEach((section) => {
      section.open = false
    })

    this.announce("All manual sections collapsed.")
  }

  clearSearch() {
    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
    }

    this.filter()
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}