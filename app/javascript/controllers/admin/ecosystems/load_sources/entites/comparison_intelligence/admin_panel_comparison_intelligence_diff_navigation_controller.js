
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["section", "position", "previous", "next"]

    connect() {
        this.currentIndex = -1
        this.sections = this.sectionTargets.filter(section => !section.hidden)
        this.updateControls()
    }

    refresh() {
        this.sections = this.sectionTargets.filter(section => !section.hidden)
        this.currentIndex = Math.min(this.currentIndex, this.sections.length - 1)
        this.updateControls()
    }

    next(event) {
        event?.preventDefault()
        this.refresh()

        if (!this.sections.length) return

        this.currentIndex = Math.min(
            this.currentIndex + 1,
            this.sections.length - 1
        )
        this.navigate()
    }

    previous(event) {
        event?.preventDefault()
        this.refresh()

        if (!this.sections.length) return

        this.currentIndex = Math.max(this.currentIndex - 1, 0)
        this.navigate()
    }

    navigate() {
        const section = this.sections[this.currentIndex]
        if (!section) return

        section.scrollIntoView({ behavior: "smooth", block: "center" })
        section.setAttribute("tabindex", "-1")
        section.focus({ preventScroll: true })
        this.updateControls()
    }

    updateControls() {
        if (this.hasPositionTarget) {
            this.positionTarget.textContent = this.sections.length
                ? `${Math.max(this.currentIndex + 1, 1)} of ${this.sections.length}`
                : "No changes to navigate"
        }

        if (this.hasPreviousTarget) {
            this.previousTarget.disabled =
                this.sections.length === 0 || this.currentIndex <= 0
        }

        if (this.hasNextTarget) {
            this.nextTarget.disabled =
                this.sections.length === 0 ||
                this.currentIndex >= this.sections.length - 1
        }
    }
}