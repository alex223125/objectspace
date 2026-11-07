
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["canvas", "layoutButton", "status"]
    static values = {
        layout: { type: String, default: "hierarchical" }
    }

    connect() {
        this.applyLayout()
    }

    choose(event) {
        event.preventDefault()

        const requested = event.currentTarget.dataset.layout
        const allowed = ["hierarchical", "radial", "force", "grid"]

        if (!allowed.includes(requested)) return

        this.layoutValue = requested
        this.applyLayout()
    }

    applyLayout() {
        if (this.hasCanvasTarget) {
            this.canvasTarget.dataset.layout = this.layoutValue
        }

        this.layoutButtonTargets.forEach(button => {
            const active = button.dataset.layout === this.layoutValue
            button.classList.toggle("is-active", active)
            button.setAttribute("aria-pressed", String(active))
        })

        if (this.hasStatusTarget) {
            const labels = {
                hierarchical: "Hierarchical layout",
                radial: "Radial layout",
                force: "Force-directed layout",
                grid: "Grid layout"
            }

            this.statusTarget.textContent =
                labels[this.layoutValue] || "Graph layout selected"
        }

        this.element.dispatchEvent(new CustomEvent("comparison-graph:layout-changed", {
            bubbles: true,
            detail: { layout: this.layoutValue }
        }))
    }
}