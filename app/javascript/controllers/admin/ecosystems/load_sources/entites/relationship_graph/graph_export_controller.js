
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        data: { type: Object, default: {} },
        filename: { type: String, default: "objectspace-relationship-graph" }
    }

    connect() {
        this.handleUpdate = this.handleUpdate.bind(this)

        this.element.addEventListener(
            "relationship-graph:updated",
            this.handleUpdate
        )
    }

    disconnect() {
        this.element.removeEventListener(
            "relationship-graph:updated",
            this.handleUpdate
        )
    }

    handleUpdate(event) {
        if (event.detail?.data) {
            this.dataValue = event.detail.data
        } else if (event.detail?.nodes || event.detail?.edges) {
            this.dataValue = {
                ...this.dataValue,
                nodes: event.detail.nodes ?? this.dataValue.nodes ?? [],
                edges: event.detail.edges ?? this.dataValue.edges ?? []
            }
        }
    }

    exportJSON() {
        this.download(
            JSON.stringify(this.dataValue, null, 2),
            "application/json;charset=utf-8",
            "json"
        )
    }

    exportNodesCSV() {
        const nodes = Array.isArray(this.dataValue.nodes)
            ? this.dataValue.nodes
            : []

        const columns = [
            ["id", "ID"],
            ["name", "Name"],
            ["slug", "Slug"],
            ["summary", "Summary"],
            ["entity_type_id", "Entity type ID"],
            ["status", "Status"],
            ["workflow_state", "Workflow state"],
            ["updated_at", "Updated at"]
        ]

        const csv = [
            columns.map(([, label]) => this.csvCell(label)).join(","),
            ...nodes.map((node) =>
                columns.map(([key]) => this.csvCell(node[key])).join(",")
            )
        ].join("\r\n")

        this.download(
            "\uFEFF" + csv,
            "text/csv;charset=utf-8",
            "entities"
        )
    }

    exportEdgesCSV() {
        const edges = Array.isArray(this.dataValue.edges)
            ? this.dataValue.edges
            : []

        const columns = [
            ["id", "ID"],
            ["source_id", "Source ID"],
            ["target_id", "Target ID"],
            ["source", "Source"],
            ["target", "Target"],
            ["relationship_type", "Relationship type"],
            ["status", "Status"],
            ["confidence", "Confidence"]
        ]

        const csv = [
            columns.map(([, label]) => this.csvCell(label)).join(","),
            ...edges.map((edge) =>
                columns.map(([key]) => this.csvCell(edge[key])).join(",")
            )
        ].join("\r\n")

        this.download(
            "\uFEFF" + csv,
            "text/csv;charset=utf-8",
            "relationships"
        )
    }

    exportSVG() {
        const svg = this.element.querySelector("svg")

        if (!svg) {
            this.announce("The graph SVG is not available for export.")
            return
        }

        const clone = svg.cloneNode(true)

        clone.setAttribute("xmlns", "http://www.w3.org/2000/svg")
        clone.setAttribute("width", "1000")
        clone.setAttribute("height", "650")

        const serializer = new XMLSerializer()
        const source = serializer.serializeToString(clone)

        this.download(
            '<?xml version="1.0" encoding="UTF-8"?>\n' + source,
            "image/svg+xml;charset=utf-8",
            "graph"
        )
    }

    csvCell(value) {
        if (value === null || value === undefined) return '""'

        const text = typeof value === "object"
            ? JSON.stringify(value)
            : String(value)

        // Prefix spreadsheet formula-like values to reduce CSV injection risk.
        const safeText = /^[\s]*[=+\-@]/.test(text)
            ? `'${text}`
            : text

        return `"${safeText.replace(/"/g, '""')}"`
    }

    download(content, mimeType, suffix) {
        const blob = new Blob([content], { type: mimeType })
        const url = URL.createObjectURL(blob)
        const anchor = document.createElement("a")

        anchor.href = url
        anchor.download = `${this.safeFilename()}-${suffix}.${this.extensionFor(mimeType)}`

        document.body.append(anchor)
        anchor.click()
        anchor.remove()

        window.setTimeout(() => URL.revokeObjectURL(url), 1000)

        this.announce(`Export prepared: ${anchor.download}`)
    }

    safeFilename() {
        return this.filenameValue
            .replace(/[^a-z0-9_-]+/gi, "-")
            .replace(/^-+|-+$/g, "") || "relationship-graph"
    }

    extensionFor(mimeType) {
        if (mimeType.startsWith("application/json")) return "json"
        if (mimeType.startsWith("text/csv")) return "csv"
        if (mimeType.startsWith("image/svg+xml")) return "svg"
        return "txt"
    }

    announce(message) {
        const status = this.element.querySelector(
            "[data-graph-export-target='status']"
        )

        if (status) status.textContent = message
    }
}