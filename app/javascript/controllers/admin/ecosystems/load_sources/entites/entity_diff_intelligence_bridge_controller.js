import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.handleDiffUpdate = this.handleDiffUpdate.bind(this)

        window.addEventListener(
            "entity-diff:updated",
            this.handleDiffUpdate
        )
    }

    disconnect() {
        window.removeEventListener(
            "entity-diff:updated",
            this.handleDiffUpdate
        )
    }

    handleDiffUpdate(event) {
        window.dispatchEvent(
            new CustomEvent("entity-diff:intelligence-refresh", {
                detail: event.detail || {}
            })
        )
    }
}