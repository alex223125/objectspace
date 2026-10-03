import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.handleReady = this.handleReady.bind(this)

        this.element.addEventListener(
            "entity-comparison-intelligence:ready",
            this.handleReady
        )
    }

    disconnect() {
        this.element.removeEventListener(
            "entity-comparison-intelligence:ready",
            this.handleReady
        )
    }

    handleReady(event) {
        const metrics = event.detail?.metrics

        if (!metrics) {
            return
        }

        this.element.dataset.intelligenceAttention =
            metrics.attention

        this.element.dataset.intelligenceRisk =
            metrics.risk

        this.element.dataset.intelligenceDensity =
            metrics.density

        this.element.dispatchEvent(
            new CustomEvent(
                "comparison:intelligence-ready",
                {
                    bubbles: true,
                    detail: {
                        metrics
                    }
                }
            )
        )
    }
}