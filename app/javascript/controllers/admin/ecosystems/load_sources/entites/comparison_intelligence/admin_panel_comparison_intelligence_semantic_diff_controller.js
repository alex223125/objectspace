
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["section", "toggle", "summary"]
    static values = {
        showUnchanged: { type: Boolean, default: false }
    }

    connect() {
        this.render()
    }

    toggleUnchanged(event) {
        this.showUnchangedValue = event.currentTarget.checked
        this.render()
    }

    render() {
        let visible = 0
        let hidden = 0

        this.sectionTargets.forEach(section => {
            const unchanged = section.dataset.diffStatus === "unchanged"
            const show = !unchanged || this.showUnchangedValue

            section.hidden = !show
            show ? visible++ : hidden++
        })

        if (this.hasSummaryTarget) {
            this.summaryTarget.textContent = hidden
                ? `${visible} sections shown; ${hidden} unchanged sections hidden.`
                : `${visible} sections shown.`
        }

        if (this.hasToggleTarget) {
            this.toggleTarget.checked = this.showUnchangedValue
        }
    }

    showAll() {
        this.showUnchangedValue = true
        this.render()
    }

    showChangesOnly() {
        this.showUnchangedValue = false
        this.render()
    }
}