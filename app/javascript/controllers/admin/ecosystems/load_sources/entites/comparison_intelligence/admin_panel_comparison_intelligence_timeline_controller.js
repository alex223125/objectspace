
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["event", "detail", "position", "previous", "next", "filter"]
    static values = { selected: Number }

    connect() {
        this.refreshEvents()
        this.selectFirst()
    }

    refreshEvents() {
        const filter = this.hasFilterTarget ? this.filterTarget.value : "all"

        this.visibleEvents = this.eventTargets.filter(event => {
            return !event.hidden &&
                (filter === "all" || event.dataset.eventType === filter)
        })

        this.updateNavigation()
    }

    filter() {
        this.refreshEvents()
        this.selectFirst()
    }

    selectFirst() {
        if (!this.visibleEvents.length) {
            this.selectedIndex = -1
            this.showDetail(null)
            this.updateNavigation()
            return
        }

        this.selectedIndex = 0
        this.selectCurrent()
    }

    previous(event) {
        event?.preventDefault()
        this.refreshEvents()

        if (this.selectedIndex > 0) {
            this.selectedIndex -= 1
            this.selectCurrent()
        }
    }

    next(event) {
        event?.preventDefault()
        this.refreshEvents()

        if (this.selectedIndex < this.visibleEvents.length - 1) {
            this.selectedIndex += 1
            this.selectCurrent()
        }
    }

    select(event) {
        event?.preventDefault()
        this.refreshEvents()

        const index = this.visibleEvents.indexOf(event.currentTarget)
        if (index < 0) return

        this.selectedIndex = index
        this.selectCurrent()
    }

    selectCurrent() {
        const current = this.visibleEvents[this.selectedIndex]

        this.eventTargets.forEach(item => {
            const active = item === current
            item.classList.toggle("is-selected", active)
            item.setAttribute("aria-pressed", String(active))
        })

        this.showDetail(current)
        this.updateNavigation()
    }

    showDetail(event) {
        if (!this.hasDetailTarget) return

        this.detailTarget.replaceChildren()

        if (!event) {
            this.detailTarget.textContent = "No timeline events match this filter."
            return
        }

        const title = document.createElement("h3")
        title.className = "text-xl font-bold"
        title.textContent = event.dataset.eventTitle || "Revision event"

        const description = document.createElement("p")
        description.className = "mt-2 text-base leading-7"
        description.textContent =
            event.dataset.eventDescription || "No additional details available."

        const metadata = document.createElement("p")
        metadata.className = "mt-3 text-base"
        metadata.textContent = [
            event.dataset.eventDate,
            event.dataset.eventAuthor,
            event.dataset.eventType
        ].filter(Boolean).join(" · ")

        this.detailTarget.append(title, description, metadata)
    }

    updateNavigation() {
        if (this.hasPositionTarget) {
            this.positionTarget.textContent = this.visibleEvents.length
                ? `${Math.max(0, this.selectedIndex) + 1} of ${this.visibleEvents.length} events`
                : "No events"
        }

        if (this.hasPreviousTarget) {
            this.previousTarget.disabled = this.selectedIndex <= 0
        }

        if (this.hasNextTarget) {
            this.nextTarget.disabled =
                this.selectedIndex < 0 ||
                this.selectedIndex >= this.visibleEvents.length - 1
        }
    }
}