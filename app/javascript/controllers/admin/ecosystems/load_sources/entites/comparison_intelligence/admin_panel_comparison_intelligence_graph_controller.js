
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["canvas", "status", "node", "zoomLabel"]
    static values = {
        zoom: { type: Number, default: 1 },
        minZoom: { type: Number, default: 0.5 },
        maxZoom: { type: Number, default: 2 }
    }

    connect() {
        this.renderZoom()
    }

    zoomIn(event) {
        event?.preventDefault()
        this.setZoom(this.zoomValue + 0.1)
    }

    zoomOut(event) {
        event?.preventDefault()
        this.setZoom(this.zoomValue - 0.1)
    }

    reset(event) {
        event?.preventDefault()
        this.setZoom(1)

        this.element.dispatchEvent(new CustomEvent("comparison-graph:reset", {
            bubbles: true
        }))
    }

    setZoom(value) {
        this.zoomValue = Math.min(
            this.maxZoomValue,
            Math.max(this.minZoomValue, value)
        )
        this.renderZoom()
    }

    renderZoom() {
        if (this.hasCanvasTarget) {
            this.canvasTarget.style.setProperty(
                "--comparison-graph-zoom",
                String(this.zoomValue)
            )
        }

        if (this.hasZoomLabelTarget) {
            this.zoomLabelTarget.textContent =
                `${Math.round(this.zoomValue * 100)}% zoom`
        }
    }

    selectNode(event) {
        const node = event.currentTarget
        const id = node.dataset.graphNodeId

        this.nodeTargets.forEach(item => {
            const selected = item === node
            item.setAttribute("aria-pressed", String(selected))
            item.classList.toggle("is-selected", selected)
        })

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                node.dataset.graphNodeLabel || "Graph node selected"
        }

        this.element.dispatchEvent(new CustomEvent("comparison-graph:node-selected", {
            bubbles: true,
            detail: {
                id: id || null,
                label: node.dataset.graphNodeLabel || "",
                type: node.dataset.graphNodeType || "unknown"
            }
        }))
    }
}