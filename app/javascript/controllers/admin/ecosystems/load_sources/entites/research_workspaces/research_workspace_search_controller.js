
import { Controller } from "@hotwired/stimulus"

// Filters only the investigation cards currently rendered on the page.
// Server-side filtering remains responsible for the complete collection.
export default class extends Controller {
    static targets = ["input", "card", "empty", "count"]

    connect() {
        this.filter()
    }

    filter() {
        const query = (this.inputTarget.value || "").trim().toLocaleLowerCase()
        let visibleCount = 0

        this.cardTargets.forEach((card) => {
            const searchableText = (
                card.dataset.searchText || card.textContent || ""
            ).toLocaleLowerCase()

            const matches = searchableText.includes(query)

            card.hidden = !matches

            if (matches) visibleCount += 1
        })

        if (this.hasEmptyTarget) {
            this.emptyTarget.hidden = visibleCount !== 0
        }

        if (this.hasCountTarget) {
            this.countTarget.textContent = String(visibleCount)
        }
    }

    clear() {
        this.inputTarget.value = ""
        this.filter()
        this.inputTarget.focus()
    }
}