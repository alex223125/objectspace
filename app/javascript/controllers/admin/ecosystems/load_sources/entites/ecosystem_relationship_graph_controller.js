import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["canvas", "svg"]
    static values = {
        payload: Object
    }

    connect() {
        this.render()
    }

    render() {
        if (!this.hasSvgTarget) return

        const graph = this.payloadValue || {}
        const nodes = graph.nodes || []
        const edges = graph.edges || []

        if (!nodes.length) return

        this.svgTarget.innerHTML = ""

        const width = 900
        const height = 320

        const positions = this.calculatePositions(
            nodes,
            width,
            height
        )

        this.drawEdges(
            edges,
            positions
        )

        this.drawNodes(
            nodes,
            positions
        )
    }

    calculatePositions(nodes, width, height) {
        const centerX = width / 2
        const centerY = height / 2

        const focusIndex =
            nodes.findIndex(
                (node) => node.focus === true
            )

        const positions = {}

        if (focusIndex >= 0) {
            const focus = nodes[focusIndex]

            positions[focus.id] = {
                x: centerX,
                y: centerY
            }

            const neighbors =
                nodes.filter(
                    (node) => node.id !== focus.id
                )

            neighbors.forEach((node, index) => {
                const angle =
                    (Math.PI * 2 * index) /
                    Math.max(neighbors.length, 1)

                const radius = 105

                positions[node.id] = {
                    x:
                        centerX +
                        Math.cos(angle) *
                        radius,

                    y:
                        centerY +
                        Math.sin(angle) *
                        radius
                }
            })
        } else {
            nodes.forEach((node, index) => {
                const columns = 4

                const column =
                    index % columns

                const row =
                    Math.floor(index / columns)

                positions[node.id] = {
                    x: 130 + column * 215,
                    y: 80 + row * 105
                }
            })
        }

        return positions
    }

    drawEdges(edges, positions) {
        edges.forEach((edge) => {
            const source =
                positions[edge.source]

            const target =
                positions[edge.target]

            if (!source || !target) return

            const line =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "line"
                )

            line.setAttribute(
                "x1",
                source.x
            )

            line.setAttribute(
                "y1",
                source.y
            )

            line.setAttribute(
                "x2",
                target.x
            )

            line.setAttribute(
                "y2",
                target.y
            )

            line.setAttribute(
                "stroke",
                this.edgeColor(edge)
            )

            line.setAttribute(
                "stroke-width",
                Math.max(
                    1.5,
                    edge.weight * 3
                )
            )

            line.setAttribute(
                "stroke-opacity",
                "0.75"
            )

            this.svgTarget.appendChild(line)
        })
    }

    drawNodes(nodes, positions) {
        nodes.forEach((node) => {
            const position =
                positions[node.id]

            if (!position) return

            const group =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "g"
                )

            const circle =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "circle"
                )

            circle.setAttribute(
                "cx",
                position.x
            )

            circle.setAttribute(
                "cy",
                position.y
            )

            circle.setAttribute(
                "r",
                node.focus ? "27" : "20"
            )

            circle.setAttribute(
                "fill",
                node.focus
                    ? "#6366f1"
                    : "#7c3aed"
            )

            circle.setAttribute(
                "stroke",
                node.focus
                    ? "#a5b4fc"
                    : "#c4b5fd"
            )

            circle.setAttribute(
                "stroke-width",
                "2"
            )

            group.appendChild(circle)

            const text =
                document.createElementNS(
                    "http://www.w3.org/2000/svg",
                    "text"
                )

            text.setAttribute(
                "x",
                position.x
            )

            text.setAttribute(
                "y",
                position.y + 42
            )

            text.setAttribute(
                "text-anchor",
                "middle"
            )

            text.setAttribute(
                "fill",
                "#e5e7eb"
            )

            text.setAttribute(
                "font-size",
                "11"
            )

            text.setAttribute(
                "font-weight",
                "700"
            )

            text.textContent =
                this.truncate(
                    node.name,
                    24
                )

            group.appendChild(text)

            this.svgTarget.appendChild(group)
        })
    }

    edgeColor(edge) {
        if (edge.confidence >= 0.8) {
            return "#34d399"
        }

        if (edge.confidence >= 0.5) {
            return "#fbbf24"
        }

        return "#94a3b8"
    }

    truncate(value, length) {
        if (!value) return ""

        if (value.length <= length) {
            return value
        }

        return `${value.slice(0, length - 1)}…`
    }
}