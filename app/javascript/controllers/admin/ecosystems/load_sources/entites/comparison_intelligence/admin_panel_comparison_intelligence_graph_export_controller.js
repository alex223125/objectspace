
import { Controller } from "@hotwired/stimulus"

export default class AdminPanelComparisonIntelligenceGraphExportController extends Controller {
    static targets = ["data", "status", "format"]
    static values = {
        filename: { type: String, default: "entity-relationship-graph" }
    }

    export(event) {
        event?.preventDefault()

        const format = this.hasFormatTarget
            ? this.formatTarget.value
            : "json"

        const raw = this.hasDataTarget
            ? this.dataTarget.textContent
            : this.element.dataset.graphData

        if (!raw) {
            this.setStatus("No graph data is available to export.")
            return
        }

        let payload

        try {
            payload = JSON.parse(raw)
        } catch {
            this.setStatus("Export failed: graph data is not valid JSON.")
            return
        }

        if (format === "json") {
            this.download(
                JSON.stringify(payload, null, 2),
                "application/json",
                "json"
            )
            return
        }

        if (format === "csv") {
            const nodes = Array.isArray(payload.nodes) ? payload.nodes : []
            const rows = [
                ["id", "label", "type", "risk"],
                ...nodes.map(node => [
                    node.id ?? "",
                    node.label ?? node.name ?? "",
                    node.type ?? "",
                    node.risk ?? ""
                ])
            ]

            const csv = rows.map(row =>
                row.map(value => {
                    const text = String(value)
                    return `"${text.replace(/"/g, '""')}"`
                }).join(",")
            ).join("\r\n")

            this.download(csv, "text/csv;charset=utf-8", "csv")
            return
        }

        this.setStatus("Choose JSON or CSV as the export format.")
    }

    download(content, type, extension) {
        const blob = new Blob([content], { type })
        const url = URL.createObjectURL(blob)
        const link = document.createElement("a")

        link.href = url
        link.download = `${this.filenameValue}.${extension}`
        link.style.display = "none"

        document.body.appendChild(link)
        link.click()
        link.remove()

        URL.revokeObjectURL(url)
        this.setStatus(`Graph data exported as ${extension.toUpperCase()}.`)
    }

    setStatus(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = message
        }
    }
}