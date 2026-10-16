
import { Controller } from "@hotwired/stimulus";

const SVG_NS = "http://www.w3.org/2000/svg";

export default class EntityEcosystemRelationshipGraphController extends Controller {
    static targets = [
        "nodeCount",
        "relationshipCount",
        "connectedCount",
        "search",
        "filter",
        "canvas",
        "svg",
        "empty",
        "details",
        "detailsTitle",
        "detailsType",
        "detailsConnections",
        "detailsDescription",
        "status",
        "xp",
        "progress",
    ];

    static values = {
        payload: Object,
    };

    connect() {
        console.group("[EcosystemGraph] CONNECT");
        console.log("Controller identifier:", this.identifier);
        console.log("Element:", this.element);
        console.log("Available targets:", {
            svg: this.hasSvgTarget,
            empty: this.hasEmptyTarget,
            search: this.hasSearchTarget,
            filter: this.hasFilterTarget,
            payload: this.hasPayloadValue,
        });

        this.selectedId = null;
        this.visitedIds = new Set();
        this.zoom = 1;
        this.minZoom = 0.5;
        this.maxZoom = 2.5;
        this.width = 900;
        this.height = 500;

        try {
            const rawPayload = this.hasPayloadValue
                ? this.payloadValue
                : {};

            console.log("Raw payload:", rawPayload);

            this.graph = this.normalizePayload(rawPayload);

            console.log("Normalized entity count:", this.graph.nodes.length);
            console.log(
                "Normalized relationship count:",
                this.graph.edges.length
            );
            console.table(
                this.graph.nodes.map((node) => ({
                    id: node.id,
                    name: node.name,
                    type: node.type,
                }))
            );
            console.table(
                this.graph.edges.map((edge) => ({
                    source: edge.source,
                    target: edge.target,
                    label: edge.label,
                    weight: edge.weight,
                }))
            );

            this.populateFilter();
            this.updateCounts();
            this.renderGraph();
            this.setEmptyMessage();

            console.log("[EcosystemGraph] CONNECT complete");
        } catch (error) {
            console.error("[EcosystemGraph] CONNECT failed:", error);
            this.showError(
                "Graph initialization failed. Check the browser console."
            );
        }

        console.groupEnd();
    }

    disconnect() {
        console.log("[EcosystemGraph] DISCONNECT");
    }

    normalizePayload(payload) {
        console.group("[EcosystemGraph] Normalize payload");

        let data = payload;

        // Accommodate common service response wrappers.
        if (data && typeof data === "object") {
            data = data.graph || data.data || data;
        }

        if (Array.isArray(data)) {
            data = { nodes: data, edges: [] };
        }

        if (!data || typeof data !== "object") {
            console.warn("Payload is empty or not an object:", data);
            data = {};
        }

        const rawNodes =
            data.nodes ||
            data.entities ||
            data.vertices ||
            data.graph_entities ||
            [];

        const rawEdges =
            data.edges ||
            data.relationships ||
            data.links ||
            data.connections ||
            [];

        if (!Array.isArray(rawNodes) || !Array.isArray(rawEdges)) {
            console.error("Unexpected graph data shape:", {
                nodes: rawNodes,
                edges: rawEdges,
            });
            console.groupEnd();

            return { nodes: [], edges: [] };
        }

        const nodes = rawNodes
            .map((item, index) => {
                if (!item || typeof item !== "object") return null;

                const id =
                    item.id ??
                    item.entity_id ??
                    item.uuid ??
                    item.slug ??
                    `entity-${index}`;

                return {
                    ...item,
                    id: String(id),
                    name: String(
                        item.name ??
                        item.title ??
                        item.label ??
                        item.display_name ??
                        `Entity ${index + 1}`
                    ),
                    type: String(
                        item.type ??
                        item.entity_type ??
                        item.kind ??
                        item.category ??
                        "unknown"
                    ),
                    description: String(
                        item.description ??
                        item.summary ??
                        item.content ??
                        ""
                    ),
                };
            })
            .filter(Boolean);

        const nodeIds = new Set(nodes.map((node) => node.id));

        const edges = rawEdges
            .map((item, index) => {
                if (!item || typeof item !== "object") return null;

                const source = this.endpointId(
                    item.source ??
                    item.source_id ??
                    item.from ??
                    item.from_id ??
                    item.subject_id ??
                    item.source_entity_id
                );

                const target = this.endpointId(
                    item.target ??
                    item.target_id ??
                    item.to ??
                    item.to_id ??
                    item.object_id ??
                    item.target_entity_id
                );

                if (!source || !target) {
                    console.warn("Skipping relationship without endpoints:", item);
                    return null;
                }

                return {
                    ...item,
                    id: String(item.id ?? `relationship-${index}`),
                    source,
                    target,
                    label: String(
                        item.label ??
                        item.relationship_type ??
                        item.relation_type ??
                        item.type ??
                        item.predicate ??
                        "related to"
                    ),
                    weight: Number(item.weight ?? item.strength ?? 1) || 1,
                };
            })
            .filter(Boolean)
            .filter((edge) => {
                const valid =
                    nodeIds.has(edge.source) && nodeIds.has(edge.target);

                if (!valid) {
                    console.warn(
                        "Skipping relationship whose endpoint is missing:",
                        edge
                    );
                }

                return valid;
            });

        console.log("Payload keys:", Object.keys(data));
        console.log("Raw nodes:", rawNodes);
        console.log("Raw edges:", rawEdges);
        console.log("Normalized result:", { nodes, edges });
        console.groupEnd();

        return { nodes, edges };
    }

    endpointId(value) {
        if (value === null || value === undefined) return null;

        if (typeof value === "object") {
            value =
                value.id ??
                value.entity_id ??
                value.uuid ??
                value.slug;
        }

        return value === null || value === undefined
            ? null
            : String(value);
    }

    populateFilter() {
        if (!this.hasFilterTarget) return;

        const currentValue = this.filterTarget.value || "all";
        const types = [
            ...new Set(this.graph.nodes.map((node) => node.type)),
        ].sort();

        this.filterTarget.replaceChildren();

        const allOption = document.createElement("option");
        allOption.value = "all";
        allOption.textContent = "All entity types";
        this.filterTarget.appendChild(allOption);

        types.forEach((type) => {
            const option = document.createElement("option");
            option.value = type;
            option.textContent = type;
            this.filterTarget.appendChild(option);
        });

        this.filterTarget.value = types.includes(currentValue)
            ? currentValue
            : "all";

        console.log("[EcosystemGraph] Filter options:", types);
    }

    search() {
        const query = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : "";

        console.log("[EcosystemGraph] SEARCH:", query);
        this.renderGraph();
    }

    filter() {
        console.log(
            "[EcosystemGraph] FILTER:",
            this.hasFilterTarget ? this.filterTarget.value : "all"
        );

        this.renderGraph();
    }

    getVisibleNodes() {
        const query = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : "";

        const type = this.hasFilterTarget
            ? this.filterTarget.value
            : "all";

        return this.graph.nodes.filter((node) => {
            const matchesType = type === "all" || node.type === type;
            const matchesQuery =
                !query ||
                node.name.toLowerCase().includes(query) ||
                node.type.toLowerCase().includes(query) ||
                node.description.toLowerCase().includes(query);

            return matchesType && matchesQuery;
        });
    }

    renderGraph() {
        if (!this.hasSvgTarget) {
            console.error("[EcosystemGraph] SVG target missing");
            return;
        }

        const svg = this.svgTarget;
        svg.replaceChildren();

        const visibleNodes = this.getVisibleNodes();
        const visibleIds = new Set(visibleNodes.map((node) => node.id));

        const visibleEdges = this.graph.edges.filter(
            (edge) =>
                visibleIds.has(edge.source) &&
                visibleIds.has(edge.target)
        );

        console.log("[EcosystemGraph] RENDER", {
            visibleNodes: visibleNodes.length,
            visibleEdges: visibleEdges.length,
            zoom: this.zoom,
        });

        this.updateCounts(visibleNodes, visibleEdges);

        if (visibleNodes.length === 0) {
            this.setEmptyMessage(
                this.graph.nodes.length === 0
                    ? "No graph entities were returned. Inspect the Rails service payload and console logs."
                    : "No entities match your search or filter."
            );
            return;
        }

        this.setEmptyMessage("");

        const positions = this.calculatePositions(visibleNodes);
        const scene = this.createSvgElement("g");

        scene.setAttribute(
            "transform",
            `translate(${this.width / 2},${this.height / 2}) scale(${this.zoom}) translate(${-this.width / 2},${-this.height / 2})`
        );

        svg.setAttribute("viewBox", `0 0 ${this.width} ${this.height}`);
        svg.appendChild(scene);

        // Draw relationships first so they appear behind the circles.
        visibleEdges.forEach((edge) => {
            const source = positions.get(edge.source);
            const target = positions.get(edge.target);

            if (!source || !target) return;

            const line = this.createSvgElement("line");
            line.setAttribute("x1", source.x);
            line.setAttribute("y1", source.y);
            line.setAttribute("x2", target.x);
            line.setAttribute("y2", target.y);
            line.setAttribute("stroke", "#94a3b8");
            line.setAttribute(
                "stroke-width",
                String(Math.min(6, Math.max(1, edge.weight)))
            );
            line.setAttribute("stroke-opacity", "0.8");

            const tooltip = this.createSvgElement("title");
            tooltip.textContent = `${edge.label}: ${source.name} → ${target.name}`;
            line.appendChild(tooltip);

            scene.appendChild(line);

            const midpoint = this.createSvgElement("text");
            midpoint.setAttribute("x", (source.x + target.x) / 2);
            midpoint.setAttribute("y", (source.y + target.y) / 2 - 5);
            midpoint.setAttribute("text-anchor", "middle");
            midpoint.setAttribute("font-size", "10");
            midpoint.setAttribute("fill", "#64748b");
            midpoint.setAttribute("pointer-events", "none");
            midpoint.textContent = edge.label;
            scene.appendChild(midpoint);
        });

        visibleNodes.forEach((node) => {
            const position = positions.get(node.id);
            const group = this.createSvgElement("g");

            group.setAttribute("role", "button");
            group.setAttribute("tabindex", "0");
            group.setAttribute("aria-label", `Select ${node.name}`);
            group.setAttribute("cursor", "pointer");
            group.dataset.entityId = node.id;

            const circle = this.createSvgElement("circle");
            circle.setAttribute("cx", position.x);
            circle.setAttribute("cy", position.y);
            circle.setAttribute("r", this.selectedId === node.id ? "15" : "11");
            circle.setAttribute("fill", this.colorForType(node.type));
            circle.setAttribute(
                "stroke",
                this.selectedId === node.id ? "#111827" : "#ffffff"
            );
            circle.setAttribute(
                "stroke-width",
                this.selectedId === node.id ? "3" : "2"
            );

            const tooltip = this.createSvgElement("title");
            tooltip.textContent = `${node.name} (${node.type})`;
            circle.appendChild(tooltip);
            group.appendChild(circle);

            const label = this.createSvgElement("text");
            label.setAttribute("x", position.x);
            label.setAttribute("y", position.y + 26);
            label.setAttribute("text-anchor", "middle");
            label.setAttribute("font-size", "12");
            label.setAttribute("fill", "currentColor");
            label.textContent =
                node.name.length > 22
                    ? `${node.name.slice(0, 19)}…`
                    : node.name;
            group.appendChild(label);

            group.addEventListener("click", () => this.selectEntity(node.id));

            group.addEventListener("keydown", (event) => {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    this.selectEntity(node.id);
                }
            });

            scene.appendChild(group);
        });

        console.log("[EcosystemGraph] SVG rendered successfully");
    }

    calculatePositions(nodes) {
        const positions = new Map();
        const centerX = this.width / 2;
        const centerY = this.height / 2;

        if (nodes.length === 1) {
            positions.set(nodes[0].id, {
                x: centerX,
                y: centerY,
                name: nodes[0].name,
            });
            return positions;
        }

        const radius = Math.min(
            this.width * 0.38,
            this.height * 0.38,
            210
        );

        nodes.forEach((node, index) => {
            const angle =
                (2 * Math.PI * index) / nodes.length - Math.PI / 2;

            positions.set(node.id, {
                x: centerX + radius * Math.cos(angle),
                y: centerY + radius * Math.sin(angle),
                name: node.name,
            });
        });

        return positions;
    }

    createSvgElement(tag) {
        return document.createElementNS(SVG_NS, tag);
    }

    colorForType(type) {
        const palette = [
            "#8b5cf6",
            "#0ea5e9",
            "#10b981",
            "#f59e0b",
            "#ec4899",
            "#6366f1",
            "#14b8a6",
            "#f97316",
        ];

        let hash = 0;

        for (let i = 0; i < type.length; i++) {
            hash = (hash * 31 + type.charCodeAt(i)) | 0;
        }

        return palette[Math.abs(hash) % palette.length];
    }

    selectEntity(id) {
        const node = this.graph.nodes.find(
            (item) => item.id === String(id)
        );

        if (!node) {
            console.warn("[EcosystemGraph] Entity not found:", id);
            return;
        }

        this.selectedId = node.id;
        this.visitedIds.add(node.id);

        const connectedIds = new Set();

        this.graph.edges.forEach((edge) => {
            if (edge.source === node.id) connectedIds.add(edge.target);
            if (edge.target === node.id) connectedIds.add(edge.source);
        });

        console.log("[EcosystemGraph] SELECT", {
            id: node.id,
            name: node.name,
            type: node.type,
            connectedIds: [...connectedIds],
        });

        if (this.hasDetailsTarget) {
            this.detailsTarget.classList.remove("hidden");
        }

        if (this.hasDetailsTitleTarget) {
            this.detailsTitleTarget.textContent = node.name;
        }

        if (this.hasDetailsTypeTarget) {
            this.detailsTypeTarget.textContent = node.type;
        }

        if (this.hasDetailsConnectionsTarget) {
            this.detailsConnectionsTarget.textContent =
                connectedIds.size;
        }

        if (this.hasDetailsDescriptionTarget) {
            this.detailsDescriptionTarget.textContent =
                node.description || "No description supplied.";
        }

        if (this.hasConnectedCountTarget) {
            this.connectedCountTarget.textContent = connectedIds.size;
        }

        if (this.hasXpTarget) {
            this.xpTarget.textContent = this.visitedIds.size;
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                `Explored ${this.visitedIds.size} of ${this.graph.nodes.length}`;
        }

        if (this.hasProgressTarget) {
            const percentage = this.graph.nodes.length
                ? (this.visitedIds.size / this.graph.nodes.length) * 100
                : 0;

            this.progressTarget.style.width = `${percentage}%`;
        }

        this.renderGraph();
    }

    updateCounts(nodes = this.graph.nodes, edges = this.graph.edges) {
        if (this.hasNodeCountTarget) {
            this.nodeCountTarget.textContent = nodes.length;
        }

        if (this.hasRelationshipCountTarget) {
            this.relationshipCountTarget.textContent = edges.length;
        }

        if (!this.selectedId && this.hasConnectedCountTarget) {
            this.connectedCountTarget.textContent = "0";
        }
    }

    zoomIn() {
        this.zoom = Math.min(this.maxZoom, this.zoom * 1.2);
        console.log("[EcosystemGraph] ZOOM IN:", this.zoom);
        this.renderGraph();
    }

    zoomOut() {
        this.zoom = Math.max(this.minZoom, this.zoom / 1.2);
        console.log("[EcosystemGraph] ZOOM OUT:", this.zoom);
        this.renderGraph();
    }

    resetView() {
        console.log("[EcosystemGraph] RESET VIEW");

        this.zoom = 1;
        this.selectedId = null;
        this.visitedIds.clear();

        if (this.hasDetailsTarget) {
            this.detailsTarget.classList.add("hidden");
        }

        if (this.hasConnectedCountTarget) {
            this.connectedCountTarget.textContent = "0";
        }

        if (this.hasXpTarget) {
            this.xpTarget.textContent = "0";
        }

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = "🧭 Begin exploring";
        }

        if (this.hasProgressTarget) {
            this.progressTarget.style.width = "0%";
        }

        this.renderGraph();
    }

    setEmptyMessage(message) {
        if (!this.hasEmptyTarget) return;

        this.emptyTarget.textContent = message;
        this.emptyTarget.classList.toggle("hidden", !message);
    }

    showError(message) {
        this.setEmptyMessage(message);
        console.error("[EcosystemGraph]", message);
    }
}