
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["viewport", "map", "indicator", "status"]
    static values = {
        scale: { type: Number, default: 1 },
        x: { type: Number, default: 0 },
        y: { type: Number, default: 0 }
    }

    connect() {
        this.update()
    }

    update() {
        if (this.hasIndicatorTarget) {
            this.indicatorTarget.style.transform =
                `translate(${this.xValue}px, ${this.yValue}px) scale(${this.scaleValue})`
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                `Graph overview position: ${Math.round(this.xValue)}, ${Math.round(this.yValue)}`
        }
    }

    center(event) {
        event?.preventDefault()
        this.xValue = 0
        this.yValue = 0
        this.scaleValue = 1
        this.update()

        this.element.dispatchEvent(new CustomEvent(
            "comparison-graph:minimap-center",
            { bubbles: true }
        ))
    }

    navigate(event) {
        const bounds = this.hasMapTarget
            ? this.mapTarget.getBoundingClientRect()
            : null

        if (!bounds || !bounds.width || !bounds.height) return

        const pointer = event.currentTarget
        const rect = pointer.getBoundingClientRect()
        const x = (event.clientX - rect.left) / rect.width
        const y = (event.clientY - rect.top) / rect.height

        this.element.dispatchEvent(new CustomEvent(
            "comparison-graph:minimap-navigate",
            {
                bubbles: true,
                detail: {
                    x: Math.max(0, Math.min(1, x)),
                    y: Math.max(0, Math.min(1, y))
                }
            }
        ))
    }

    disconnect() {
        this.element.dispatchEvent(new CustomEvent(
            "comparison-graph:minimap-disconnected",
            { bubbles: true }
        ))
    }
}