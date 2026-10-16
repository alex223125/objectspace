import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["trigger", "card"]

    connect() {
        this.hideTimeout = null
        this.frame = null
        this.onViewportChange = this.reposition.bind(this)
    }

    disconnect() {
        this.cancelHide()

        if (this.frame !== null) {
            cancelAnimationFrame(this.frame)
            this.frame = null
        }

        window.removeEventListener("resize", this.onViewportChange)
        window.removeEventListener("scroll", this.onViewportChange, true)
    }

    show() {
        this.cancelHide()

        if (!this.hasCardTarget || !this.hasTriggerTarget) return

        this.cardTarget.hidden = false
        this.cardTarget.classList.remove("hidden")
        this.cardTarget.setAttribute("aria-hidden", "false")
        this.triggerTarget.setAttribute("aria-expanded", "true")

        this.reposition()

        window.removeEventListener("resize", this.onViewportChange)
        window.removeEventListener("scroll", this.onViewportChange, true)

        window.addEventListener("resize", this.onViewportChange)
        window.addEventListener("scroll", this.onViewportChange, true)
    }

    scheduleHide(event) {
        if (event?.relatedTarget && this.element.contains(event.relatedTarget)) {
            return
        }

        this.cancelHide()

        this.hideTimeout = window.setTimeout(() => {
            const activeElementInside = this.element.contains(document.activeElement)
            const pointerInside = this.element.matches(":hover")

            if (!activeElementInside && !pointerInside) {
                this.close()
            }
        }, 160)
    }

    cancelHide() {
        if (this.hideTimeout !== null) {
            window.clearTimeout(this.hideTimeout)
            this.hideTimeout = null
        }
    }

    close() {
        this.cancelHide()

        if (!this.hasCardTarget) return

        this.cardTarget.hidden = true
        this.cardTarget.classList.add("hidden")
        this.cardTarget.setAttribute("aria-hidden", "true")

        if (this.hasTriggerTarget) {
            this.triggerTarget.setAttribute("aria-expanded", "false")
        }

        window.removeEventListener("resize", this.onViewportChange)
        window.removeEventListener("scroll", this.onViewportChange, true)
    }

    reposition() {
        if (!this.hasCardTarget || !this.hasTriggerTarget) return
        if (this.cardTarget.hidden) return

        if (this.frame !== null) {
            cancelAnimationFrame(this.frame)
        }

        this.frame = requestAnimationFrame(() => {
            this.frame = null

            const trigger = this.triggerTarget.getBoundingClientRect()
            const card = this.cardTarget
            const margin = 12
            const gap = 8

            const viewportWidth = document.documentElement.clientWidth
            const viewportHeight = window.innerHeight

            const cardWidth = card.getBoundingClientRect().width
            const cardHeight = card.getBoundingClientRect().height

            let left = trigger.left
            let top = trigger.bottom + gap

            if (left + cardWidth > viewportWidth - margin) {
                left = viewportWidth - cardWidth - margin
            }

            left = Math.max(margin, left)

            if (top + cardHeight > viewportHeight - margin) {
                const above = trigger.top - cardHeight - gap

                if (above >= margin) {
                    top = above
                } else {
                    top = Math.max(
                        margin,
                        viewportHeight - cardHeight - margin
                    )
                }
            }

            card.style.left = `${left}px`
            card.style.top = `${top}px`
        })
    }
}