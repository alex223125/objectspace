
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["node", "edge", "filter", "count", "emptyState"]

    connect() {
        this.apply()
    }

    change() {
        this.apply()
    }

    apply() {
        const enabledTypes = new Set(
            this.filterTargets
                .filter(input => input.checked)
                .map(input => input.value)
        )

        let visibleNodes = 0

        this.nodeTargets.forEach(node => {
            const type = node.dataset.graphNodeType || "other"
            const visible = enabledTypes.size === 0 || enabledTypes.has(type)

            node.hidden = !visible
            node.setAttribute("aria-hidden", String(!visible))

            if (visible) visibleNodes += 1
        })

        const visibleNodeIds = new Set(
            this.nodeTargets
                .filter(node => !node.hidden)
                .map(node => node.dataset.graphNodeId)
        )

        let visibleEdges = 0

        this.edgeTargets.forEach(edge => {
            const source = edge.dataset.sourceNodeId
            const target = edge.dataset.targetNodeId
            const visible = visibleNodeIds.has(source) && visibleNodeIds.has(target)

            edge.hidden = !visible
            if (visible) visibleEdges += 1
        })

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${visibleNodes} nodes and ${visibleEdges} relationships visible`
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visibleNodes > 0
        }

        this.element.dispatchEvent(new CustomEvent("comparison-graph:filters-changed", {
            bubbles: true,
            detail: {
                visibleNodes,
                visibleEdges,
                types: Array.from(enabledTypes)
            }
        }))
    }

    showAll() {
        this.filterTargets.forEach(input => {
            input.checked = true
        })
        this.apply()
    }

    clear() {
        this.filterTargets.forEach(input => {
            input.checked = false
        })
        this.apply()
    }
}