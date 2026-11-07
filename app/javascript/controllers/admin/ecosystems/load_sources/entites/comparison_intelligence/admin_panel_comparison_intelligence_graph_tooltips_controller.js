
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["tooltip", "title", "description", "metadata"]

    connect() {
        this.hide()
    }

    show(event) {
        const source = event.currentTarget
        const data = source.dataset

        if (!this.hasTooltipTarget) return

        if (this.hasTitleTarget) {
            this.titleTarget.textContent =
                data.tooltipTitle || data.graphNodeLabel || "Entity details"
        }

        if (this.hasDescriptionTarget) {
            this.descriptionTarget.textContent =
                data.tooltipDescription ||
                data.graphNodeDescription ||
                "No additional details are available."
        }

        if (this.hasMetadataTarget) {
            const details = [
                data.graphNodeType && `Type: ${data.graphNodeType}`,
                data.entityLocation && `Location: ${data.entityLocation}`,
                data.graphRisk && `Risk: ${data.graphRisk}`,
                data.entityVersion && `Version: ${data.entityVersion}`
            ].filter(Boolean)

            this.metadataTarget.replaceChildren(
                ...details.map(text => {
                    const item = document.createElement("p")
                    item.textContent = text
                    return item
                })
            )
        }

        this.tooltipTarget.hidden = false
        this.tooltipTarget.setAttribute("role", "tooltip")
        source.setAttribute("aria-describedby", this.tooltipTarget.id || "")

        const rect = source.getBoundingClientRect()
        this.tooltipTarget.style.position = "fixed"
        this.tooltipTarget.style.left = `${Math.max(8, Math.min(
            rect.left,
            window.innerWidth - this.tooltipTarget.offsetWidth - 8
        ))}px`

        this.tooltipTarget.style.top = `${Math.min(
            rect.bottom + 8,
            window.innerHeight - this.tooltipTarget.offsetHeight - 8
        )}px`
    }

    hide(event) {
        if (!this.hasTooltipTarget) return

        this.tooltipTarget.hidden = true

        if (event?.currentTarget) {
            event.currentTarget.removeAttribute("aria-describedby")
        }
    }
}