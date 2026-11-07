
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["node", "details", "selectedCount", "clearButton"]
    static values = {
        multiple: { type: Boolean, default: false }
    }

    connect() {
        this.selectedIds = new Set()
        this.sync()
    }

    toggle(event) {
        event.preventDefault()

        const node = event.currentTarget
        const id = node.dataset.graphNodeId
        if (!id) return

        if (this.selectedIds.has(id)) {
            this.selectedIds.delete(id)
        } else {
            if (!this.multipleValue) this.selectedIds.clear()
            this.selectedIds.add(id)
        }

        this.sync()

        this.element.dispatchEvent(new CustomEvent("comparison-graph:selection-changed", {
            bubbles: true,
            detail: { ids: Array.from(this.selectedIds) }
        }))
    }

    selectAll() {
        if (!this.multipleValue) return

        this.nodeTargets.forEach(node => {
            if (node.dataset.graphNodeId) {
                this.selectedIds.add(node.dataset.graphNodeId)
            }
        })

        this.sync()
    }

    clear(event) {
        event?.preventDefault()
        this.selectedIds.clear()
        this.sync()
    }

    sync() {
        this.nodeTargets.forEach(node => {
            const selected = this.selectedIds.has(node.dataset.graphNodeId)
            node.classList.toggle("is-selected", selected)
            node.setAttribute("aria-pressed", String(selected))
        })

        if (this.hasSelectedCountTarget) {
            const count = this.selectedIds.size
            this.selectedCountTarget.textContent =
                `${count} ${count === 1 ? "node" : "nodes"} selected`
        }

        if (this.hasClearButtonTarget) {
            this.clearButtonTarget.disabled = this.selectedIds.size === 0
        }

        if (this.hasDetailsTarget) {
            this.detailsTarget.hidden = this.selectedIds.size === 0
        }
    }
}