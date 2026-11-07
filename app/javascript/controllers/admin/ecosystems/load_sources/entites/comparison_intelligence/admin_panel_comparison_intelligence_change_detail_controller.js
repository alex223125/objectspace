
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["drawer", "title", "body", "path", "risk", "trigger"]
    static values = {
        open: { type: Boolean, default: false }
    }

    connect() {
        this.syncVisibility()
        this.onKeydown = this.handleKeydown.bind(this)
        document.addEventListener("keydown", this.onKeydown)
    }

    disconnect() {
        document.removeEventListener("keydown", this.onKeydown)
    }

    open(event) {
        event?.preventDefault()

        const trigger = event?.currentTarget
        const data = trigger?.dataset || {}

        if (this.hasTitleTarget) {
            this.titleTarget.textContent = data.changeTitle || "Change details"
        }

        if (this.hasBodyTarget) {
            this.bodyTarget.textContent =
                data.changeDescription || "No additional description is available."
        }

        if (this.hasPathTarget) {
            this.pathTarget.textContent = data.changePath || "Path not supplied"
        }

        if (this.hasRiskTarget) {
            this.riskTarget.textContent =
                data.changeRisk || "Risk has not been assessed"
        }

        this.previousFocus = trigger
        this.openValue = true
        this.syncVisibility()

        this.element.dispatchEvent(new CustomEvent("comparison-detail:opened", {
            bubbles: true,
            detail: { changeId: data.changeId || null }
        }))
    }

    close(event) {
        event?.preventDefault()
        this.openValue = false
        this.syncVisibility()

        if (this.previousFocus?.isConnected) {
            this.previousFocus.focus()
        }
    }

    handleKeydown(event) {
        if (event.key === "Escape" && this.openValue) {
            this.close(event)
        }
    }

    syncVisibility() {
        if (!this.hasDrawerTarget) return

        this.drawerTarget.hidden = !this.openValue
        this.drawerTarget.setAttribute(
            "aria-hidden",
            String(!this.openValue)
        )

        if (this.openValue) {
            const focusable = this.drawerTarget.querySelector(
                "button, a[href], input, select, textarea, [tabindex]:not([tabindex='-1'])"
            )
            focusable?.focus()
        }
    }
}