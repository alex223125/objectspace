import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "canvas",
        "search",
        "filter",
        "totalNodes",
        "totalRelationships",
        "activeNodes",
        "selected",
        "details",
        "detailsTitle",
        "detailsType",
        "detailsDescription",
        "detailsStats",
        "legend",
        "empty"
    ]

    static values = {
        nodes: Array,
        relationships: Array
    }

    connect() {
        this.currentFilter = "all"
        this.selectedNodeId = null

        this.initializeGraph()
    }

    disconnect() {
        this.clearGraph()
    }

    initializeGraph() {
        this.nodes = this.normalizedNodes()
        this.relationships = this.normalizedRelationships()

        this.renderMetrics()
        this.renderLegend()
        this.renderGraph()
        this.renderDetails()
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
                `Node ${index + 1}`,

            type:
                node.type ||
                node.category ||
                "entity",

            description:
                node.description ||
                node.summary ||
                "",

            activity: Number(
                node.activity ??
                node.changes ??
                node.change_count ??
                0
            ),

            changes: Number(
                node.changes ??
                node.change_count ??
                0
            ),

            versions: Number(
                node.versions ??
                node.version_count ??
                0
            ),

            metadata:
                node.metadata ||
                {}
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
                    relationship.relationship ||
                    "related",

                strength: Number(
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

    renderMetrics() {
        if (this.hasTotalNodesTarget) {
            this.totalNodesTarget.textContent =
                this.nodes.length
        }

        if (this.hasTotalRelationshipsTarget) {
            this.totalRelationshipsTarget.textContent =
                this.relationships.length
        }

        if (this.hasActiveNodesTarget) {
            this.activeNodesTarget.textContent =
                this.nodes.filter(
                    node => node.activity > 0
                ).length
        }
    }

    renderLegend() {
        if (!this.hasLegendTarget) {
            return
        }

        const types = [
            "problem",
            "method",
            "algorithm",
            "technology",
            "entity",
            "version"
        ]

        this.legendTarget.innerHTML =
            types
                .map(type => `
          <div class="flex items-center gap-2">
            <span
              class="h-3 w-3 rounded-full ${this.typeColor(type)}">
            </span>

            <span
              class="text-[9px] font-black uppercase tracking-wider text-slate-400">
              ${this.escapeHtml(type)}
            </span>
          </div>
        `)
                .join("")
    }

    renderGraph() {
        if (!this.hasCanvasTarget) {
            return
        }

        const query =
            this.hasSearchTarget
                ? this.searchTarget.value
                    .trim()
                    .toLowerCase()
                : ""

        const filteredNodes =
            this.nodes.filter(node => {
                const matchesSearch =
                    !query ||
                    node.name
                        .toLowerCase()
                        .includes(query) ||
                    node.type
                        .toLowerCase()
                        .includes(query)

                const matchesType =
                    this.currentFilter === "all" ||
                    node.type === this.currentFilter

                return (
                    matchesSearch &&
                    matchesType
                )
            })

        if (
            filteredNodes.length === 0
        ) {
            this.renderEmptyState()
            return
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.add(
                "hidden"
            )
        }

        const visibleIds =
            new Set(
                filteredNodes.map(
                    node => node.id
                )
            )

        const filteredRelationships =
            this.relationships.filter(
                relationship =>
                    visibleIds.has(
                        relationship.source
                    ) &&
                    visibleIds.has(
                        relationship.target
                    )
            )

        const layout =
            this.calculateLayout(
                filteredNodes
            )

        this.canvasTarget.innerHTML =
            this.buildSvg(
                filteredNodes,
                filteredRelationships,
                layout
            )
    }

    calculateLayout(nodes) {
        const width = 1000
        const height = 560

        const centerX = width / 2
        const centerY = height / 2

        const radius =
            Math.min(
                210,
                Math.max(
                    120,
                    60 +
                    nodes.length * 7
                )
            )

        const positions = {}

        nodes.forEach(
            (node, index) => {
                const angle =
                    (
                        index /
                        Math.max(nodes.length, 1)
                    ) *
                    Math.PI *
                    2 -
                    Math.PI / 2

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
            }
        )

        return {
            width,
            height,
            positions
        }
    }

    buildSvg(
        nodes,
        relationships,
        layout
    ) {
        const nodeMap =
            new Map(
                nodes.map(node => [
                    node.id,
                    node
                ])
            )

        const relationshipMarkup =
            relationships
                .map(
                    relationship => {
                        const source =
                            layout.positions[
                                relationship.source
                                ]

                        const target =
                            layout.positions[
                                relationship.target
                                ]

                        if (!source || !target) {
                            return ""
                        }

                        return `
              <line
                x1="${source.x}"
                y1="${source.y}"
                x2="${target.x}"
                y2="${target.y}"
                stroke="#cbd5e1"
                stroke-width="${Math.max(
                            1,
                            Math.min(
                                4,
                                relationship.strength
                            )
                        )}"
                stroke-opacity="0.65"
                stroke-dasharray="${
                            relationship.type === "depends_on"
                                ? "5 5"
                                : "0"
                        }"
                data-relationship="${this.escapeHtml(
                            relationship.type
                        )}">
              </line>
            `
                    }
                )
                .join("")

        const nodeMarkup =
            nodes
                .map(
                    node => {
                        const position =
                            layout.positions[
                                node.id
                                ]

                        const radius =
                            this.nodeRadius(
                                node
                            )

                        const selected =
                            String(
                                this.selectedNodeId
                            ) ===
                            String(node.id)

                        return `
              <g
                class="cursor-pointer"
                data-node-id="${this.escapeHtml(
                            node.id
                        )}"
                data-action="click->entity-ecosystem-graph#selectNode"
                transform="translate(${position.x},${position.y})">

                ${
                            selected
                                ? `
                      <circle
                        r="${radius + 10}"
                        fill="none"
                        stroke="${this.typeHex(
                                    node.type
                                )}"
                        stroke-width="3"
                        stroke-opacity="0.25">
                      </circle>
                    `
                                : ""
                        }

                <circle
                  r="${radius + 5}"
                  fill="${this.typeHex(
                            node.type
                        )}"
                  opacity="0.10">
                </circle>

                <circle
                  r="${radius}"
                  fill="white"
                  stroke="${this.typeHex(
                            node.type
                        )}"
                  stroke-width="3"
                  class="transition-all duration-300">

                </circle>

                <text
                  y="-2"
                  text-anchor="middle"
                  class="pointer-events-none"
                  fill="#334155"
                  font-size="12"
                  font-weight="900">

                  ${this.escapeHtml(
                            this.truncate(
                                node.name,
                                16
                            )
                        )}

                </text>

                <text
                  y="15"
                  text-anchor="middle"
                  class="pointer-events-none"
                  fill="#94a3b8"
                  font-size="8"
                  font-weight="800"
                  text-transform="uppercase">

                  ${this.escapeHtml(
                            node.type
                        )}

                </text>

                <title>
                  ${this.escapeHtml(
                            node.name
                        )}
                  ·
                  ${this.escapeHtml(
                            node.type
                        )}
                </title>

              </g>
            `
                    }
                )
                .join("")

        const center =
            `
        <circle
          cx="${layout.width / 2}"
          cy="${layout.height / 2}"
          r="58"
          fill="#fff7ed"
          stroke="#fdba74"
          stroke-width="2">
        </circle>

        <circle
          cx="${layout.width / 2}"
          cy="${layout.height / 2}"
          r="46"
          fill="white"
          stroke="#fed7aa"
          stroke-width="1">
        </circle>

        <text
          x="${layout.width / 2}"
          y="${layout.height / 2 - 4}"
          text-anchor="middle"
          fill="#c2410c"
          font-size="12"
          font-weight="900">

          ECOSYSTEM

        </text>

        <text
          x="${layout.width / 2}"
          y="${layout.height / 2 + 14}"
          text-anchor="middle"
          fill="#94a3b8"
          font-size="8"
          font-weight="800">

          INTELLIGENCE

        </text>
      `

        return `
      <svg
        viewBox="0 0 ${layout.width} ${layout.height}"
        class="h-auto w-full"
        role="img"
        aria-label="Ecosystem relationship graph">

        <defs>
          <radialGradient
            id="ecosystemGraphBackground"
            cx="50%"
            cy="50%"
            r="70%">

            <stop
              offset="0%"
              stop-color="#fff7ed">
            </stop>

            <stop
              offset="55%"
              stop-color="#ffffff">
            </stop>

            <stop
              offset="100%"
              stop-color="#f8fafc">
            </stop>

          </radialGradient>
        </defs>

        <rect
          width="${layout.width}"
          height="${layout.height}"
          rx="32"
          fill="url(#ecosystemGraphBackground)">
        </rect>

        <g>
          ${relationshipMarkup}
        </g>

        ${center}

        <g>
          ${nodeMarkup}
        </g>

      </svg>
    `
    }

    nodeRadius(node) {
        const activity =
            Math.max(
                0,
                Math.min(
                    100,
                    node.activity
                )
            )

        return 28 +
            Math.round(
                activity / 12
            )
    }

    selectNode(event) {
        const nodeId =
            event.currentTarget.dataset.nodeId

        this.selectedNodeId =
            String(nodeId)

        this.renderGraph()
        this.renderDetails()
    }

    renderDetails() {
        if (
            !this.hasDetailsTarget
        ) {
            return
        }

        const node =
            this.nodes.find(
                candidate =>
                    String(candidate.id) ===
                    String(this.selectedNodeId)
            )

        if (!node) {
            this.detailsTarget.classList.add(
                "hidden"
            )

            return
        }

        this.detailsTarget.classList.remove(
            "hidden"
        )

        if (this.hasDetailsTitleTarget) {
            this.detailsTitleTarget.textContent =
                node.name
        }

        if (this.hasDetailsTypeTarget) {
            this.detailsTypeTarget.textContent =
                node.type
        }

        if (this.hasDetailsDescriptionTarget) {
            this.detailsDescriptionTarget.textContent =
                node.description ||
                "No additional description has been provided for this ecosystem node."
        }

        const connections =
            this.relationships.filter(
                relationship =>
                    String(
                        relationship.source
                    ) === String(node.id) ||
                    String(
                        relationship.target
                    ) === String(node.id)
            )

        if (this.hasDetailsStatsTarget) {
            this.detailsStatsTarget.innerHTML = `
        ${this.detailMetric(
                "Activity",
                node.activity
            )}

        ${this.detailMetric(
                "Changes",
                node.changes
            )}

        ${this.detailMetric(
                "Versions",
                node.versions
            )}

        ${this.detailMetric(
                "Connections",
                connections.length
            )}
      `
        }

        if (this.hasSelectedTarget) {
            this.selectedTarget.textContent =
                node.name
        }
    }

    detailMetric(
        label,
        value
    ) {
        return `
      <div
        class="rounded-xl bg-slate-50 px-3 py-2 text-center">

        <div
          class="text-[8px] font-black uppercase tracking-widest text-slate-400">

          ${this.escapeHtml(label)}

        </div>

        <div
          class="mt-1 text-sm font-black text-slate-600">

          ${this.escapeHtml(value)}

        </div>

      </div>
    `
    }

    filter(event) {
        this.currentFilter =
            event.currentTarget.value

        this.selectedNodeId =
            null

        this.renderGraph()
        this.renderDetails()
    }

    search() {
        this.renderGraph()
        this.renderDetails()
    }

    focusEcosystem() {
        this.currentFilter = "all"
        this.selectedNodeId = null

        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        if (this.hasFilterTarget) {
            this.filterTarget.value = "all"
        }

        this.renderGraph()
        this.renderDetails()
    }

    renderEmptyState() {
        if (this.hasCanvasTarget) {
            this.canvasTarget.innerHTML = ""
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.remove(
                "hidden"
            )
        }
    }

    clearGraph() {
        if (this.hasCanvasTarget) {
            this.canvasTarget.innerHTML = ""
        }
    }

    typeColor(type) {
        const colors = {
            problem:
                "bg-orange-400",

            method:
                "bg-sky-400",

            algorithm:
                "bg-violet-400",

            technology:
                "bg-emerald-400",

            entity:
                "bg-indigo-400",

            version:
                "bg-amber-400"
        }

        return (
            colors[type] ||
            "bg-slate-400"
        )
    }

    typeHex(type) {
        const colors = {
            problem:
                "#fb923c",

            method:
                "#38bdf8",

            algorithm:
                "#a78bfa",

            technology:
                "#34d399",

            entity:
                "#818cf8",

            version:
                "#fbbf24"
        }

        return (
            colors[type] ||
            "#94a3b8"
        )
    }

    truncate(
        value,
        length
    ) {
        const string =
            String(value)

        if (
            string.length <= length
        ) {
            return string
        }

        return (
            string.slice(
                0,
                length - 1
            ) + "…"
        )
    }

    escapeHtml(value) {
        return String(value)
            .replaceAll(
                "&",
                "&amp;"
            )
            .replaceAll(
                "<",
                "&lt;"
            )
            .replaceAll(
                ">",
                "&gt;"
            )
            .replaceAll(
                '"',
                "&quot;"
            )
            .replaceAll(
                "'",
                "&#039;"
            )
    }
}