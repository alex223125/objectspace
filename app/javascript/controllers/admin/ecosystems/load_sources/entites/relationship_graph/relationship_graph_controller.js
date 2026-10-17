
import { Controller } from "@hotwired/stimulus"

/**
 * Relationship Graph coordinator.
 *
 * Optional markup:
 * data-controller="relationship-graph"
 * data-relationship-graph-node-count-value="12"
 * data-relationship-graph-edge-count-value="0"
 */
export default class extends Controller {
    static values = {
        nodeCount: { type: Number, default: 0 },
        edgeCount: { type: Number, default: 0 },
        endpoint: String
    }

    static targets = ["status", "nodeCount", "edgeCount", "announcement"]

    connect() {
        this.element.dataset.relationshipGraphReady = "true"
        this.updateMetrics()

        this.handleGraphUpdated = this.handleGraphUpdated.bind(this)
        this.handleEntitySelected = this.handleEntitySelected.bind(this)

        this.element.addEventListener(
            "relationship-graph:updated",
            this.handleGraphUpdated
        )

        this.element.addEventListener(
            "relationship-graph:entity-selected",
            this.handleEntitySelected
        )
    }

    disconnect() {
        this.element.removeEventListener(
            "relationship-graph:updated",
            this.handleGraphUpdated
        )

        this.element.removeEventListener(
            "relationship-graph:entity-selected",
            this.handleEntitySelected
        )

        delete this.element.dataset.relationshipGraphReady
    }

    updateMetrics() {
        if (this.hasNodeCountTarget) {
            this.nodeCountTargets.forEach((target) => {
                target.textContent = this.formatNumber(this.nodeCountValue)
            })
        }

        if (this.hasEdgeCountTarget) {
            this.edgeCountTargets.forEach((target) => {
                target.textContent = this.formatNumber(this.edgeCountValue)
            })
        }
    }

    handleGraphUpdated(event) {
        const detail = event.detail || {}

        if (Number.isFinite(Number(detail.nodeCount))) {
            this.nodeCountValue = Number(detail.nodeCount)
        }

        if (Number.isFinite(Number(detail.edgeCount))) {
            this.edgeCountValue = Number(detail.edgeCount)
        }

        this.updateMetrics()

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                this.nodeCountValue === 0
                    ? "No graph data"
                    : this.edgeCountValue === 0
                        ? "Connections needed"
                        : "Graph available"
        }

        this.announce(
            `Graph updated: ${this.nodeCountValue} entities and ${this.edgeCountValue} relationships.`
        )
    }

    handleEntitySelected(event) {
        const entity = event.detail?.entity
        if (!entity) return

        this.announce(`Selected entity: ${entity.name || entity.id}.`)
    }

    announce(message) {
        if (this.hasAnnouncementTarget) {
            this.announcementTarget.textContent = message
        }

        this.dispatch("announcement", {
            detail: { message },
            bubbles: true
        })
    }

    formatNumber(value) {
        return new Intl.NumberFormat().format(value)
    }
}