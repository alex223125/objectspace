import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "search"
    ]

    connect() {
        this.boundKeydown =
            this.handleKeydown.bind(this)

        document.addEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    disconnect() {
        document.removeEventListener(
            "keydown",
            this.boundKeydown
        )
    }

    handleKeydown(event) {
        const tag =
            event.target?.tagName?.toLowerCase()

        const editing =
            tag === "input" ||
            tag === "textarea" ||
            tag === "select" ||
            event.target?.isContentEditable

        if (
            (event.metaKey || event.ctrlKey) &&
            event.key.toLowerCase() === "k"
        ) {
            event.preventDefault()

            if (this.hasSearchTarget) {
                this.searchTarget.focus()
                this.searchTarget.select()
            }

            return
        }

        if (
            editing &&
            event.key === "Escape"
        ) {
            event.target.blur()
        }
    }
}