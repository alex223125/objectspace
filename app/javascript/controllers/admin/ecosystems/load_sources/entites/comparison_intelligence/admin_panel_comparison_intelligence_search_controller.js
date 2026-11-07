
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "clearButton", "status"]

    static values = {
        minLength: { type: Number, default: 0 }
    }

    connect() {
        this.onInput = this.onInput.bind(this)
        this.inputTarget?.addEventListener("input", this.onInput)
        this.publishQuery()
    }

    disconnect() {
        this.inputTarget?.removeEventListener("input", this.onInput)
    }

    onInput() {
        this.publishQuery()
    }

    submit(event) {
        event?.preventDefault()

        const query = this.query

        this.dispatch("submitted", {
            detail: { query }
        })
    }

    clear(event) {
        event?.preventDefault()

        if (!this.hasInputTarget) return

        this.inputTarget.value = ""
        this.inputTarget.focus()
        this.publishQuery()
    }

    get query() {
        return this.hasInputTarget
            ? this.inputTarget.value.trim()
            : ""
    }

    publishQuery() {
        const query = this.query
        const valid = query.length >= this.minLengthValue

        if (this.hasClearButtonTarget) {
            this.clearButtonTarget.hidden = query.length === 0
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = valid
                ? (query ? `Searching for ${query}` : "Search cleared")
                : `Enter at least ${this.minLengthValue} characters`
        }

        this.dispatch("changed", {
            detail: {
                query: valid ? query : "",
                valid
            }
        })
    }
}