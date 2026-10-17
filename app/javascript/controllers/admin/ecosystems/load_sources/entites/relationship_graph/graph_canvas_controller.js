
import { Controller } from "@hotwired/stimulus"

const SVG_NS = "http://www.w3.org/2000/svg"

const TYPE_COLORS = {
    1: { fill: "#fff7ed", stroke: "#fb923c", text: "#9a3412" },
    2: { fill: "#f0f9ff", stroke: "#38bdf8", text: "#075985" },
    3: { fill: "#f5f3ff", stroke: "#a78bfa", text: "#5b21b6" },
    4: { fill: "#ecfdf5", stroke: "#34d399", text: "#065f46" },
    6: { fill: "#fff7ed", stroke: "#f59e0b", text: "#92400e" }
}

const DEFAULT_COLORS = {
    fill: "#fff7ed",
    stroke: "#fb923c",
    text: "#9a3412"
}

export default class extends Controller {
    static targets = [
        "svg",
        "hint",
        "search",
        "directory",
        "dossier",
        "resultCount"
    ]

    static values = {
        data: { type: Object, default: {} }
    }

    connect() {
        this.selectedId = null
        this.positions = new Map()
        this.visibleNodes = []
        this.resizeObserver = null

        this.normalizeData()
        this.render()

        if (typeof ResizeObserver !== "undefined" && this.hasSvgTarget) {
            this.resizeObserver = new ResizeObserver(() => this.fit())
            this.resizeObserver.observe(this.svgTarget)
        }


        this.handleSearchResults = (event) => {
            const payload = event.detail?.payload

            if (
                !payload ||
                !Array.isArray(payload.nodes) ||
                !Array.isArray(payload.edges)
            ) {
                return
            }

            this.dataValue = payload
            this.normalizeData()

            // Clear a selection that isn't in the new results.
            if (!this.nodes.some((node) => node.id === this.selectedId)) {
                this.selectedId = null
            }

            this.render()
        }

        document.addEventListener(
            "relationship-graph:search-results",
            this.handleSearchResults
        )
    }

    disconnect() {
        this.resizeObserver?.disconnect()
        this.resizeObserver = null


        if (this.handleSearchResults) {
            document.removeEventListener(
                "relationship-graph:search-results",
                this.handleSearchResults
            )

            this.handleSearchResults = null
        }
    }

    normalizeData() {
        const data = this.dataValue || {}

        this.nodes = Array.isArray(data.nodes)
            ? data.nodes.map((node) => ({ ...node, id: String(node.id) }))
            : []

        this.edges = Array.isArray(data.edges)
            ? data.edges.map((edge) => ({ ...edge }))
            : []

        this.meta = data.meta || {}
        this.visibleNodes = [...this.nodes]
    }

    render() {
        if (!this.hasSvgTarget) return

        this.positions.clear()
        this.svgTarget.replaceChildren()

        const width = 1000
        const height = 650

        this.svgTarget.setAttribute("viewBox", `0 0 ${width} ${height}`)
        this.svgTarget.setAttribute("role", "group")
        this.svgTarget.setAttribute(
            "aria-label",
            "Interactive network of entities and relationships"
        )

        const background = this.svgElement("rect", {
            x: 0,
            y: 0,
            width,
            height,
            rx: 24,
            fill: "#fffdf9"
        })

        background.setAttribute("aria-hidden", "true")
        this.svgTarget.append(background)

        const edgeLayer = this.svgElement("g", {
            "data-layer": "relationships",
            "aria-label": "Relationships"
        })

        const nodeLayer = this.svgElement("g", {
            "data-layer": "entities",
            "aria-label": "Entities"
        })

        this.svgTarget.append(edgeLayer, nodeLayer)

        this.layoutNodes(width, height)
        this.renderEdges(edgeLayer)
        this.renderNodes(nodeLayer)
        this.renderDirectory()
        this.updateResultCount()
        this.updateHint()
    }

    layoutNodes(width, height) {
        const count = this.visibleNodes.length
        if (!count) return

        const centerX = width / 2
        const centerY = height / 2
        const radius = Math.min(width * 0.37, height * 0.36)

        this.visibleNodes.forEach((node, index) => {
            const angle = (2 * Math.PI * index) / Math.max(count, 1) - Math.PI / 2

            this.positions.set(node.id, {
                x: count === 1 ? centerX : centerX + Math.cos(angle) * radius,
                y: count === 1 ? centerY : centerY + Math.sin(angle) * radius
            })
        })
    }

    renderEdges(layer) {
        this.edges.forEach((edge) => {
            const sourceId = String(
                edge.source_id ?? edge.source ?? edge.from ?? ""
            )

            const targetId = String(
                edge.target_id ?? edge.target ?? edge.to ?? ""
            )

            const source = this.positions.get(sourceId)
            const target = this.positions.get(targetId)

            if (!source || !target) return

            const line = this.svgElement("line", {
                x1: source.x,
                y1: source.y,
                x2: target.x,
                y2: target.y,
                stroke: "#f0b67f",
                "stroke-width": 2.5,
                "stroke-linecap": "round",
                "data-source": sourceId,
                "data-target": targetId
            })

            layer.append(line)
        })
    }

    renderNodes(layer) {
        this.visibleNodes.forEach((node) => {
            const position = this.positions.get(node.id)
            if (!position) return

            const colors = TYPE_COLORS[node.entity_type_id] || DEFAULT_COLORS
            const selected = node.id === this.selectedId

            const group = this.svgElement("g", {
                transform: `translate(${position.x}, ${position.y})`,
                role: "button",
                tabindex: 0,
                "aria-label": `Inspect ${node.name || `entity ${node.id}`}`,
                "aria-pressed": String(selected),
                "data-node-id": node.id,
                style: "cursor:pointer"
            })

            const title = this.svgElement("title")
            title.textContent =
                `${node.name || "Unnamed entity"} — ID ${node.id}. Select to inspect.`

            const circle = this.svgElement("circle", {
                r: selected ? 17 : 14,
                fill: colors.fill,
                stroke: selected ? "#ea580c" : colors.stroke,
                "stroke-width": selected ? 4 : 2.5
            })

            const label = this.svgElement("text", {
                x: 0,
                y: 34,
                fill: "#334155",
                "font-size": 14,
                "font-weight": selected ? 800 : 650,
                "text-anchor": "middle",
                "pointer-events": "none"
            })

            label.textContent = this.truncate(node.name || `Entity ${node.id}`, 22)

            group.append(title, circle, label)

            group.addEventListener("click", () => this.selectNode(node.id))

            group.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault()
                    this.selectNode(node.id)
                }
            })

            layer.append(group)
        })
    }

    renderDirectory() {
        if (!this.hasDirectoryTarget) return

        this.directoryTarget.replaceChildren()

        this.visibleNodes.forEach((node) => {
            const button = document.createElement("button")
            button.type = "button"
            button.dataset.graphCanvasNodeId = node.id
            button.dataset.action = "graph-canvas#selectFromDirectory"

            button.className = [
                "block w-full rounded-2xl border-2 p-4 text-left transition",
                "focus:outline-none focus:ring-4 focus:ring-orange-100",
                node.id === this.selectedId
                    ? "border-orange-300 bg-orange-50"
                    : "border-orange-100 bg-white hover:border-orange-300 hover:bg-orange-50/50"
            ].join(" ")

            const name = document.createElement("span")
            name.className = "block break-words text-base font-extrabold text-slate-800"
            name.textContent = node.name || `Entity ${node.id}`

            const id = document.createElement("span")
            id.className = "mt-2 block font-mono text-xs text-slate-600"
            id.textContent = `ID: ${node.id}`

            button.append(name, id)

            if (node.summary) {
                const summary = document.createElement("span")
                summary.className = "mt-2 block break-words text-sm leading-6 text-slate-600"
                summary.textContent = node.summary
                button.append(summary)
            }

            this.directoryTarget.append(button)
        })
    }

    selectFromDirectory(event) {
        const button = event.currentTarget
        const id = button.dataset.graphCanvasNodeId

        if (id) this.selectNode(id)
    }

    selectNode(id) {
        const node = this.nodes.find((item) => item.id === String(id))
        if (!node) return

        this.selectedId = node.id

        this.render()
        this.renderDossier(node)

        this.dispatch("entity-selected", {
            detail: { entity: node },
            bubbles: true
        })

        this.element.dispatchEvent(
            new CustomEvent("relationship-graph:entity-selected", {
                bubbles: true,
                detail: { entity: node }
            })
        )

        this.updateHint(`Selected ${node.name || `entity ${node.id}`}.`)
    }

    renderDossier(node) {
        if (!this.hasDossierTarget) return

        const panel = this.dossierTarget
        panel.replaceChildren()

        const eyebrow = document.createElement("p")
        eyebrow.className = "text-xs font-black uppercase tracking-widest text-orange-700"
        eyebrow.textContent = "Entity encyclopedia"

        const heading = document.createElement("h3")
        heading.className = "mt-3 break-words text-2xl font-black text-slate-800"
        heading.textContent = node.name || `Entity ${node.id}`

        const description = document.createElement("p")
        description.className = "mt-3 break-words text-base leading-7 text-slate-600"
        description.textContent = node.summary || "No description is available for this entity."

        const metadata = document.createElement("dl")
        metadata.className = "mt-6 grid gap-3 sm:grid-cols-2"

        const fields = [
            ["Entity ID", node.id],
            ["Slug", node.slug],
            ["Status", node.status || node.workflow_state],
            ["Type ID", node.entity_type_id]
        ]

        fields.forEach(([label, value]) => {
            if (value === undefined || value === null || value === "") return

            const item = document.createElement("div")
            item.className = "rounded-xl border border-orange-100 bg-orange-50/50 p-4"

            const term = document.createElement("dt")
            term.className = "text-xs font-bold uppercase tracking-wide text-slate-500"
            term.textContent = label

            const detail = document.createElement("dd")
            detail.className = "mt-2 break-words text-sm font-bold text-slate-800"
            detail.textContent = String(value)

            item.append(term, detail)
            metadata.append(item)
        })

        panel.append(eyebrow, heading, description, metadata)
    }

    search(event) {
        const query = String(event.currentTarget.value || "")
            .trim()
            .toLocaleLowerCase()

        this.visibleNodes = this.nodes.filter((node) => {
            const haystack = [
                node.name,
                node.id,
                node.slug,
                node.summary,
                node.status,
                node.workflow_state,
                node.entity_type_id
            ].filter(Boolean).join(" ").toLocaleLowerCase()

            return haystack.includes(query)
        })

        if (
            this.selectedId &&
            !this.visibleNodes.some((node) => node.id === this.selectedId)
        ) {
            this.selectedId = null
            if (this.hasDossierTarget) {
                this.dossierTarget.textContent = "Select an entity to inspect its details."
            }
        }

        this.render()
    }

    // fit() {d
    //     if (!this.hasSvgTarget) return
    //
    //     this.svgTarget.setAttribute("preserveAspectRatio", "xMidYMid meet")
    //     this.svgTarget.setAttribute("viewBox", "0 0 1000 650")
    // }


    fit() {
        console.group("[GraphCanvas] Fit graph");
        console.log("Button action reached fit()");
        console.log("Controller element:", this.element);
        console.log("SVG target exists:", this.hasSvgTarget);

        try {
            if (!this.hasSvgTarget) {
                console.error("[GraphCanvas] Missing SVG target.");
                console.groupEnd();
                return;
            }

            const svg = this.svgTarget;

            // 1. Make the graph container use the available horizontal space.
            const container =
                svg.closest("[data-graph-container]") ||
                svg.parentElement;

            if (container) {
                console.log("[GraphCanvas] Graph container:", container);

                container.style.width = "100%";
                container.style.maxWidth = "none";
                container.style.minWidth = "0";
                container.style.boxSizing = "border-box";

                // Expand the graph's immediate section without changing
                // the entire page or unrelated panels.
                const section = container.parentElement;

                if (section) {
                    const computed = window.getComputedStyle(section);

                    if (
                        computed.maxWidth !== "none" &&
                        section.classList.contains("container")
                    ) {
                        section.style.maxWidth = "none";
                        section.style.width = "100%";
                    }
                }
            }

            // 2. Make the SVG responsive.
            svg.style.display = "block";
            svg.style.width = "100%";
            svg.style.maxWidth = "none";
            svg.style.height = "auto";
            svg.style.minHeight = "420px";
            svg.style.overflow = "visible";
            svg.setAttribute("preserveAspectRatio", "xMidYMid meet");

            // 3. Measure the actual rendered entities and relationships.
            const nodeLayer = svg.querySelector('[data-layer="entities"]');
            const edgeLayer = svg.querySelector('[data-layer="relationships"]');

            console.log("Entity layer:", nodeLayer);
            console.log("Relationship layer:", edgeLayer);
            console.log("Visible entities:", this.visibleNodes.length);
            console.log("Relationships:", this.edges.length);

            let bounds = null;

            // Prefer actual SVG geometry, including text labels.
            for (const layer of [edgeLayer, nodeLayer]) {
                if (!layer || !layer.children.length) continue;

                try {
                    const box = layer.getBBox();

                    console.log("[GraphCanvas] Layer bounds:", {
                        layer: layer.dataset.layer,
                        x: box.x,
                        y: box.y,
                        width: box.width,
                        height: box.height
                    });

                    if (
                        Number.isFinite(box.x) &&
                        Number.isFinite(box.y) &&
                        Number.isFinite(box.width) &&
                        Number.isFinite(box.height) &&
                        (box.width > 0 || box.height > 0)
                    ) {
                        if (!bounds) {
                            bounds = {
                                minX: box.x,
                                minY: box.y,
                                maxX: box.x + box.width,
                                maxY: box.y + box.height
                            };
                        } else {
                            bounds.minX = Math.min(bounds.minX, box.x);
                            bounds.minY = Math.min(bounds.minY, box.y);
                            bounds.maxX = Math.max(bounds.maxX, box.x + box.width);
                            bounds.maxY = Math.max(bounds.maxY, box.y + box.height);
                        }
                    }
                } catch (error) {
                    console.warn("[GraphCanvas] Could not measure layer:", error);
                }
            }

            // 4. Fall back to the known node positions if SVG measurement fails.
            if (!bounds && this.positions.size > 0) {
                console.warn("[GraphCanvas] Using node positions as fallback.");

                const points = [...this.positions.values()];

                bounds = {
                    minX: Math.min(...points.map(point => point.x)),
                    minY: Math.min(...points.map(point => point.y)),
                    maxX: Math.max(...points.map(point => point.x)),
                    maxY: Math.max(...points.map(point => point.y))
                };
            }

            // 5. If there is no graph data, restore the default viewport.
            if (!bounds) {
                console.warn("[GraphCanvas] No measurable graph; using default view.");

                svg.setAttribute("viewBox", "0 0 1000 650");

                console.groupEnd();
                return;
            }

            const padding = 65;

            let x = bounds.minX - padding;
            let y = bounds.minY - padding;
            let width = bounds.maxX - bounds.minX + padding * 2;
            let height = bounds.maxY - bounds.minY + padding * 2;

            // Protect against zero-sized or invalid viewports.
            width = Math.max(width, 100);
            height = Math.max(height, 100);

            // Use a wide viewport for a wide graph, without stretching nodes.
            const containerWidth = container?.clientWidth || svg.clientWidth || 1000;
            const aspectRatio = Math.max(
                1,
                Math.min(containerWidth / Math.max(height, 1), 3)
            );

            width = Math.max(width, height * aspectRatio);

            // Center the expanded viewport around the graph.
            const graphCenterX = (bounds.minX + bounds.maxX) / 2;
            const graphCenterY = (bounds.minY + bounds.maxY) / 2;

            x = graphCenterX - width / 2;
            y = graphCenterY - height / 2;

            console.log("[GraphCanvas] Final fit:", {
                x,
                y,
                width,
                height,
                containerWidth,
                aspectRatio
            });

            // 6. Apply the final viewport.
            svg.setAttribute("viewBox", `${x} ${y} ${width} ${height}`);

            // The background rectangle must cover the new viewport.
            const background = svg.querySelector("rect");

            if (background) {
                background.setAttribute("x", String(x));
                background.setAttribute("y", String(y));
                background.setAttribute("width", String(width));
                background.setAttribute("height", String(height));
            }

            // 7. Report success and make the final viewport easy to inspect.
            console.log("[GraphCanvas] Applied viewBox:", svg.getAttribute("viewBox"));
            console.log("[GraphCanvas] SVG dimensions:", {
                width: svg.clientWidth,
                height: svg.clientHeight
            });

            this.updateHint("Graph fitted to the available view.");

        } catch (error) {
            console.error("[GraphCanvas] Fit failed:", error);
        } finally {
            console.groupEnd();
        }
    }

    reset() {
        this.selectedId = null

        if (this.hasSearchTarget) {
            this.searchTarget.value = ""
        }

        this.visibleNodes = [...this.nodes]
        this.render()

        if (this.hasDossierTarget) {
            this.dossierTarget.textContent =
                "Select an entity to inspect its classification, metadata, and available relationships."
        }

        this.updateHint("Selection cleared. Choose an entity to explore.")
    }

    updateResultCount() {
        if (!this.hasResultCountTarget) return

        this.resultCountTarget.textContent =
            `${this.visibleNodes.length} of ${this.nodes.length} entities`
    }

    updateHint(message) {
        if (!this.hasHintTarget) return

        this.hintTarget.textContent = message ||
            (this.edges.length === 0
                ? "No relationships were returned. Select an entity to inspect its details."
                : "Select a node to inspect its connections and source data.")
    }

    truncate(value, length) {
        const text = String(value)
        return text.length > length ? `${text.slice(0, length - 1)}…` : text
    }

    svgElement(name, attributes = {}) {
        const element = document.createElementNS(SVG_NS, name)

        Object.entries(attributes).forEach(([key, value]) => {
            element.setAttribute(key, String(value))
        })

        return element
    }
}