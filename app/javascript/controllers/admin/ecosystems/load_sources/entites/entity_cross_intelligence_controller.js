import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "graph",
        "relationship",
        "count",
        "empty",
        "signal",
        "search"
    ]

    connect() {
        this.renderGraph()
    }

    renderGraph() {
        if (!this.hasGraphTarget) return

        const payload = this.readGraphPayload()

        if (!payload || !payload.nodes) {
            return
        }

        this.graphTarget.innerHTML = ""

        if (payload.nodes.length === 0) {
            return
        }

        const root =
            payload.nodes.find((node) => node.root) ||
            payload.nodes[0]

        const others =
            payload.nodes.filter((node) => node.id !== root.id)

        const width = 900
        const height = 360

        const centerX = width / 2
        const centerY = height / 2

        const svg =
            document.createElementNS(
                "http://www.w3.org/2000/svg",
                "svg"
            )

        svg.setAttribute("viewBox", `0 0 ${width} ${height}`)
        svg.setAttribute("class", "h-full w-full")

        const positions = new Map()

        positions.set(root.id, {
            x: centerX,
            y: centerY
        })

        const radius = Math.min(
            125,
            70 + others.length * 7
        )

        others.forEach((node, index) => {
            const angle =
                (Math.PI * 2 * index) /
                Math.max(others.length, 1)

            positions.set(node.id, {
                x: centerX + Math.cos(angle) * radius * 2.1,
                y: centerY + Math.sin(angle) * radius
            })
        })

        payload.edges.forEach((edge) => {
            const source = positions.get(edge.source)
            const target = positions.get(edge.target)

            if (!source || !target) return

            const line =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "line"
                )

            line.setAttribute("x1", source.x)
            line.setAttribute("y1", source.y)
            line.setAttribute("x2", target.x)
            line.setAttribute("y2", target.y)

            line.setAttribute(
                "stroke",
                this.edgeColor(edge.strength)
            )

            line.setAttribute(
                "stroke-width",
                Math.max(
                    1,
                    Math.min(5, edge.strength / 25)
                )
            )

            line.setAttribute(
                "stroke-opacity",
                "0.55"
            )

            svg.appendChild(line)
        })

        payload.nodes.forEach((node) => {
            const position = positions.get(node.id)

            if (!position) return

            const group =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "g"
                )

            group.style.cursor = "pointer"

            const circle =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "circle"
                )

            circle.setAttribute("cx", position.x)
            circle.setAttribute("cy", position.y)

            circle.setAttribute(
                "r",
                node.root ? "30" : "22"
            )

            circle.setAttribute(
                "fill",
                node.root
                    ? "#6366f1"
                    : this.nodeColor(node.status)
            )

            circle.setAttribute(
                "fill-opacity",
                node.root ? "1" : "0.9"
            )

            circle.setAttribute(
                "stroke",
                node.root ? "#c7d2fe" : "#ffffff"
            )

            circle.setAttribute(
                "stroke-width",
                node.root ? "3" : "2"
            )

            group.appendChild(circle)

            const label =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "text"
                )

            label.setAttribute(
                "x",
                position.x
            )

            label.setAttribute(
                "y",
                position.y + 48
            )

            label.setAttribute(
                "text-anchor",
                "middle"
            )

            label.setAttribute(
                "fill",
                "#cbd5e1"
            )

            label.setAttribute(
                "font-size",
                "11"
            )

            label.setAttribute(
                "font-weight",
                "700"
            )

            label.textContent =
                this.truncate(node.label, 24)

            group.appendChild(label)

            const title =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "title"
                )

            title.textContent =
                `${node.label} · ${node.type || "Entity"}`

            group.appendChild(title)

            svg.appendChild(group)
        })

        this.graphTarget.appendChild(svg)
    }

    filterRelationships() {
        if (!this.hasSearchTarget) return

        const query =
            this.searchTarget.value
                .toLowerCase()
                .trim()

        this.relationshipTargets.forEach((element) => {
            const text =
                element.textContent
                    .toLowerCase()

            element.classList.toggle(
                "hidden",
                query.length > 0 &&
                !text.includes(query)
            )
        })
    }

    readGraphPayload() {
        const element =
            this.element.querySelector(
                "[data-entity-cross-intelligence-graph]"
            )

        if (!element) return null

        try {
            return JSON.parse(
                element.textContent
            )
        } catch (error) {
            console.error(
                "Invalid cross-entity graph payload",
                error
            )

            return null
        }
    }

    edgeColor(strength) {
        if (strength >= 80) return "#8b5cf6"
        if (strength >= 60) return "#38bdf8"
        if (strength >= 40) return "#f59e0b"

        return "#64748b"
    }

    nodeColor(status) {
        switch (status) {
            case "published":
                return "#10b981"

            case "deprecated":
                return "#ef4444"

            case "archived":
                return "#64748b"

            default:
                return "#f59e0b"
        }
    }

    truncate(value, length) {
        if (!value) return ""

        if (value.length <= length) {
            return value
        }

        return `${value.slice(0, length - 1)}…`
    }
}