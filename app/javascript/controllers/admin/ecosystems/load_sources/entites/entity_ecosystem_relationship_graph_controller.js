import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "canvas",
        "search",
        "filter",
        "nodeCount",
        "relationshipCount",
        "connectedCount",
        "xp",
        "progress",
        "status",
        "details",
        "detailsTitle",
        "detailsType",
        "detailsConnections",
        "detailsDescription",
        "empty"
    ]

    static values = {
        nodes: Array,
        relationships: Array
    }

    connect() {
        this.currentFilter = "all"
        this.selectedNode = null
        this.hoveredNode = null
        this.scale = 1
        this.offsetX = 0
        this.offsetY = 0
        this.dragging = false
        this.lastPointer = null

        this.discoveryXp = 0
        this.discoveredNodes = new Set()

        this.render()
        this.bindPointerEvents()
    }

    disconnect() {
        this.unbindPointerEvents()
    }

    render() {
        this.nodes = this.normalizedNodes()
        this.relationships = this.normalizedRelationships()

        this.updateMetrics()
        this.updateFilterOptions()
        this.drawGraph()
        this.updateProgress()
    }

    normalizedNodes() {
        if (!Array.isArray(this.nodesValue)) {
            return []
        }

        return this.nodesValue.map((node, index) => ({
            id: String(node.id ?? `node-${index}`),

            name:
                node.name ||
                node.title ||
                node.label ||
                `Entity ${index + 1}`,

            type:
                node.type ||
                node.category ||
                "Entity",

            description:
                node.description ||
                node.summary ||
                "",

            connections: Number(
                node.connections ??
                node.connection_count ??
                0
            ),

            color:
                node.color ||
                this.colorForType(
                    node.type ||
                    node.category
                ),

            x:
                Number(node.x) ||
                this.defaultX(index),

            y:
                Number(node.y) ||
                this.defaultY(index)
        }))
    }

    normalizedRelationships() {
        if (!Array.isArray(this.relationshipsValue)) {
            return []
        }

        return this.relationshipsValue
            .map((relationship, index) => ({
                id:
                    String(
                        relationship.id ??
                        `relationship-${index}`
                    ),

                source:
                    String(
                        relationship.source ??
                        relationship.from ??
                        ""
                    ),

                target:
                    String(
                        relationship.target ??
                        relationship.to ??
                        ""
                    ),

                type:
                    relationship.type ||
                    relationship.label ||
                    relationship.relationship ||
                    "related",

                strength:
                    Number(
                        relationship.strength ??
                        relationship.weight ??
                        1
                    )
            }))
            .filter(
                relationship =>
                    relationship.source &&
                    relationship.target
            )
    }

    defaultX(index) {
        const columns = 5
        const column = index % columns
        const row = Math.floor(index / columns)

        return 100 + column * 180
    }

    defaultY(index) {
        const columns = 5
        const row = Math.floor(index / columns)

        return 90 + row * 140
    }

    colorForType(type) {
        const normalized =
            String(type || "")
                .toLowerCase()

        if (
            normalized.includes("problem") ||
            normalized.includes("threat")
        ) {
            return "#fb923c"
        }

        if (
            normalized.includes("method")
        ) {
            return "#38bdf8"
        }

        if (
            normalized.includes("algorithm")
        ) {
            return "#a78bfa"
        }

        if (
            normalized.includes("architecture") ||
            normalized.includes("technology")
        ) {
            return "#34d399"
        }

        if (
            normalized.includes("version")
        ) {
            return "#f59e0b"
        }

        return "#94a3b8"
    }

    updateMetrics() {
        if (this.hasNodeCountTarget) {
            this.nodeCountTarget.textContent =
                this.nodes.length
        }

        if (this.hasRelationshipCountTarget) {
            this.relationshipCountTarget.textContent =
                this.relationships.length
        }

        if (this.hasConnectedCountTarget) {
            const connected =
                this.selectedNode
                    ? this.connectedNodes(
                        this.selectedNode.id
                    ).length
                    : 0

            this.connectedCountTarget.textContent =
                connected
        }
    }

    updateFilterOptions() {
        if (!this.hasFilterTarget) {
            return
        }

        const current =
            this.filterTarget.value || "all"

        const types = [
            ...new Set(
                this.nodes.map(node => node.type)
            )
        ]
            .filter(Boolean)
            .sort()

        this.filterTarget.innerHTML = `
      <option value="all">
        All entity types
      </option>

      ${types
            .map(
                type => `
            <option value="${this.escapeHtml(type)}">
              ${this.escapeHtml(type)}
            </option>
          `
            )
            .join("")}
    `

        if (
            types.includes(current) ||
            current === "all"
        ) {
            this.filterTarget.value =
                current
        }
    }

    visibleNodes() {
        const query =
            this.hasSearchTarget
                ? this.searchTarget.value
                    .trim()
                    .toLowerCase()
                : ""

        return this.nodes.filter(node => {
            const matchesSearch =
                !query ||
                node.name
                    .toLowerCase()
                    .includes(query) ||
                node.type
                    .toLowerCase()
                    .includes(query)

            const matchesFilter =
                this.currentFilter === "all" ||
                node.type === this.currentFilter

            return (
                matchesSearch &&
                matchesFilter
            )
        })
    }

    visibleRelationships(nodes) {
        const ids = new Set(
            nodes.map(node => node.id)
        )

        return this.relationships.filter(
            relationship =>
                ids.has(relationship.source) &&
                ids.has(relationship.target)
        )
    }

    drawGraph() {
        if (!this.hasCanvasTarget) {
            return
        }

        const svg =
            this.canvasTarget

        const nodes =
            this.visibleNodes()

        const relationships =
            this.visibleRelationships(nodes)

        svg.innerHTML = ""

        this.drawDefinitions(svg)

        const graph =
            document.createElementNS(
                "http://www.w3.org/2000/svg",
                "g"
            )

        graph.setAttribute(
            "transform",
            `translate(${this.offsetX} ${this.offsetY}) scale(${this.scale})`
        )

        svg.appendChild(graph)

        this.drawRelationships(
            graph,
            relationships
        )

        this.drawNodes(
            graph,
            nodes
        )

        if (
            this.hasEmptyTarget
        ) {
            this.emptyTarget.classList.toggle(
                "hidden",
                nodes.length > 0
            )
        }
    }

    drawDefinitions(svg) {
        const defs =
            document.createElementNS(
                "http://www.w3.org/2000/svg",
                "defs"
            )

        const shadow =
            document.createElementNS(
                "http://www.w3.org/2000/svg",
                "filter"
            )

        shadow.setAttribute(
            "id",
            "graph-shadow"
        )

        shadow.innerHTML = `
      <feDropShadow
        dx="0"
        dy="3"
        stdDeviation="4"
        flood-color="#64748b"
        flood-opacity="0.16"
      />
    `

        defs.appendChild(shadow)

        svg.appendChild(defs)
    }

    drawRelationships(
        graph,
        relationships
    ) {
        relationships.forEach(
            relationship => {
                const source =
                    this.nodes.find(
                        node =>
                            node.id ===
                            relationship.source
                    )

                const target =
                    this.nodes.find(
                        node =>
                            node.id ===
                            relationship.target
                    )

                if (
                    !source ||
                    !target
                ) {
                    return
                }

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
                    "#cbd5e1"
                )

                line.setAttribute(
                    "stroke-width",
                    Math.max(
                        1,
                        Math.min(
                            4,
                            relationship.strength
                        )
                    )
                )

                line.setAttribute(
                    "stroke-linecap",
                    "round"
                )

                line.setAttribute(
                    "opacity",
                    "0.75"
                )

                if (
                    this.selectedNode &&
                    (
                        relationship.source ===
                        this.selectedNode.id ||
                        relationship.target ===
                        this.selectedNode.id
                    )
                ) {
                    line.setAttribute(
                        "stroke",
                        "#fb923c"
                    )

                    line.setAttribute(
                        "stroke-width",
                        "3"
                    )

                    line.setAttribute(
                        "opacity",
                        "1"
                    )
                }

                graph.appendChild(line)

                this.drawRelationshipLabel(
                    graph,
                    relationship,
                    source,
                    target
                )
            }
        )
    }

    drawRelationshipLabel(
        graph,
        relationship,
        source,
        target
    ) {
        const text =
            document.createElementNS(
                "http://www.w3.org/2000/svg",
                "text"
            )

        text.textContent =
            relationship.type

        text.setAttribute(
            "x",
            (source.x + target.x) / 2
        )

        text.setAttribute(
            "y",
            (source.y + target.y) / 2 - 6
        )

        text.setAttribute(
            "text-anchor",
            "middle"
        )

        text.setAttribute(
            "font-size",
            "8"
        )

        text.setAttribute(
            "font-weight",
            "700"
        )

        text.setAttribute(
            "fill",
            "#94a3b8"
        )

        text.setAttribute(
            "pointer-events",
            "none"
        )

        graph.appendChild(text)
    }

    drawNodes(graph, nodes) {
        nodes.forEach(
            node => {
                const group =
                    document.createElementNS(
                        "http://www.w3.org/2000/svg",
                        "g"
                    )

                group.dataset.nodeId =
                    node.id

                group.style.cursor =
                    "pointer"

                const isSelected =
                    this.selectedNode &&
                    this.selectedNode.id ===
                    node.id

                const isConnected =
                    this.selectedNode &&
                    this.connectedNodes(
                        this.selectedNode.id
                    ).some(
                        connected =>
                            connected.id === node.id
                    )

                const circle =
                    document.createElementNS(
                        "http://www.w3.org/2000/svg",
                        "circle"
                    )

                circle.setAttribute(
                    "cx",
                    node.x
                )

                circle.setAttribute(
                    "cy",
                    node.y
                )

                circle.setAttribute(
                    "r",
                    isSelected ? "28" : "23"
                )

                circle.setAttribute(
                    "fill",
                    node.color
                )

                circle.setAttribute(
                    "stroke",
                    isSelected
                        ? "#f97316"
                        : "#ffffff"
                )

                circle.setAttribute(
                    "stroke-width",
                    isSelected ? "5" : "4"
                )

                circle.setAttribute(
                    "filter",
                    "url(#graph-shadow)"
                )

                circle.setAttribute(
                    "opacity",
                    this.selectedNode &&
                    !isSelected &&
                    !isConnected
                        ? "0.35"
                        : "1"
                )

                group.appendChild(circle)

                const shortLabel =
                    document.createElementNS(
                        "http://www.w3.org/2000/svg",
                        "text"
                    )

                shortLabel.textContent =
                    this.initials(node.name)

                shortLabel.setAttribute(
                    "x",
                    node.x
                )

                shortLabel.setAttribute(
                    "y",
                    node.y + 5
                )

                shortLabel.setAttribute(
                    "text-anchor",
                    "middle"
                )

                shortLabel.setAttribute(
                    "font-size",
                    "11"
                )

                shortLabel.setAttribute(
                    "font-weight",
                    "900"
                )

                shortLabel.setAttribute(
                    "fill",
                    "#ffffff"
                )

                shortLabel.setAttribute(
                    "pointer-events",
                    "none"
                )

                group.appendChild(
                    shortLabel
                )

                const label =
                    document.createElementNS(
                        "http://www.w3.org/2000/svg",
                        "text"
                    )

                label.textContent =
                    this.truncate(
                        node.name,
                        24
                    )

                label.setAttribute(
                    "x",
                    node.x
                )

                label.setAttribute(
                    "y",
                    node.y + 43
                )

                label.setAttribute(
                    "text-anchor",
                    "middle"
                )

                label.setAttribute(
                    "font-size",
                    "10"
                )

                label.setAttribute(
                    "font-weight",
                    "800"
                )

                label.setAttribute(
                    "fill",
                    "#475569"
                )

                label.setAttribute(
                    "pointer-events",
                    "none"
                )

                group.appendChild(
                    label
                )

                group.addEventListener(
                    "click",
                    event => {
                        event.stopPropagation()

                        this.selectNode(node)
                    }
                )

                group.addEventListener(
                    "mouseenter",
                    () => {
                        this.hoveredNode =
                            node

                        this.updateDetails(
                            node
                        )
                    }
                )

                group.addEventListener(
                    "mouseleave",
                    () => {
                        this.hoveredNode =
                            null
                    }
                )

                graph.appendChild(group)
            }
        )
    }

    selectNode(node) {
        this.selectedNode =
            node

        if (
            !this.discoveredNodes.has(
                node.id
            )
        ) {
            this.discoveredNodes.add(
                node.id
            )

            this.discoveryXp += 10

            if (
                this.hasXpTarget
            ) {
                this.xpTarget.textContent =
                    this.discoveryXp
            }
        }

        this.updateDetails(node)
        this.updateMetrics()
        this.updateProgress()
        this.drawGraph()
    }

    updateDetails(node) {
        if (
            !this.hasDetailsTarget ||
            !node
        ) {
            return
        }

        const connected =
            this.connectedNodes(
                node.id
            )

        this.detailsTarget.classList.remove(
            "hidden"
        )

        if (
            this.hasDetailsTitleTarget
        ) {
            this.detailsTitleTarget.textContent =
                node.name
        }

        if (
            this.hasDetailsTypeTarget
        ) {
            this.detailsTypeTarget.textContent =
                node.type
        }

        if (
            this.hasDetailsConnectionsTarget
        ) {
            this.detailsConnectionsTarget.textContent =
                connected.length
        }

        if (
            this.hasDetailsDescriptionTarget
        ) {
            this.detailsDescriptionTarget.textContent =
                node.description ||
                "Explore connected entities to uncover the ecosystem structure."
        }
    }

    connectedNodes(nodeId) {
        const ids =
            new Set()

        this.relationships.forEach(
            relationship => {
                if (
                    relationship.source ===
                    nodeId
                ) {
                    ids.add(
                        relationship.target
                    )
                }

                if (
                    relationship.target ===
                    nodeId
                ) {
                    ids.add(
                        relationship.source
                    )
                }
            }
        )

        return this.nodes.filter(
            node =>
                ids.has(node.id)
        )
    }

    updateProgress() {
        if (
            !this.hasProgressTarget
        ) {
            return
        }

        const total =
            this.nodes.length

        const discovered =
            this.discoveredNodes.size

        const percentage =
            total === 0
                ? 0
                : Math.round(
                    (discovered / total) *
                    100
                )

        this.progressTarget.style.width =
            `${Math.min(
                percentage,
                100
            )}%`

        if (
            this.hasStatusTarget
        ) {
            if (
                percentage >= 80
            ) {
                this.statusTarget.textContent =
                    "🏆 Ecosystem cartographer"
            } else if (
                percentage >= 50
            ) {
                this.statusTarget.textContent =
                    "🔥 Deep exploration"
            } else if (
                percentage >= 20
            ) {
                this.statusTarget.textContent =
                    "✨ Knowledge explorer"
            } else {
                this.statusTarget.textContent =
                    "🧭 Begin exploring"
            }
        }
    }

    search() {
        this.drawGraph()
    }

    filter(event) {
        this.currentFilter =
            event.currentTarget.value

        this.drawGraph()
    }

    zoomIn() {
        this.scale =
            Math.min(
                2.5,
                this.scale + 0.15
            )

        this.drawGraph()
    }

    zoomOut() {
        this.scale =
            Math.max(
                0.45,
                this.scale - 0.15
            )

        this.drawGraph()
    }

    resetView() {
        this.scale = 1
        this.offsetX = 0
        this.offsetY = 0
        this.selectedNode = null

        this.drawGraph()
        this.updateMetrics()

        if (
            this.hasDetailsTarget
        ) {
            this.detailsTarget.classList.add(
                "hidden"
            )
        }
    }

    bindPointerEvents() {
        if (!this.hasCanvasTarget) {
            return
        }

        this.pointerDownHandler =
            event => {
                this.dragging = true
                this.lastPointer = {
                    x: event.clientX,
                    y: event.clientY
                }
            }

        this.pointerMoveHandler =
            event => {
                if (
                    !this.dragging ||
                    !this.lastPointer
                ) {
                    return
                }

                const dx =
                    event.clientX -
                    this.lastPointer.x

                const dy =
                    event.clientY -
                    this.lastPointer.y

                this.offsetX += dx
                this.offsetY += dy

                this.lastPointer = {
                    x: event.clientX,
                    y: event.clientY
                }

                this.drawGraph()
            }

        this.pointerUpHandler =
            () => {
                this.dragging = false
                this.lastPointer = null
            }

        this.canvasTarget.addEventListener(
            "pointerdown",
            this.pointerDownHandler
        )

        window.addEventListener(
            "pointermove",
            this.pointerMoveHandler
        )

        window.addEventListener(
            "pointerup",
            this.pointerUpHandler
        )
    }

    unbindPointerEvents() {
        if (
            this.canvasTarget &&
            this.pointerDownHandler
        ) {
            this.canvasTarget.removeEventListener(
                "pointerdown",
                this.pointerDownHandler
            )
        }

        if (this.pointerMoveHandler) {
            window.removeEventListener(
                "pointermove",
                this.pointerMoveHandler
            )
        }

        if (this.pointerUpHandler) {
            window.removeEventListener(
                "pointerup",
                this.pointerUpHandler
            )
        }
    }

    initials(name) {
        return String(name)
            .split(/\s+/)
            .slice(0, 2)
            .map(
                word => word.charAt(0)
            )
            .join("")
            .toUpperCase()
    }

    truncate(value, length) {
        const string =
            String(value || "")

        return string.length <= length
            ? string
            : `${string.slice(
                0,
                length - 1
            )}…`
    }

    escapeHtml(value) {
        return String(value)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;")
    }
}