
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["workspace", "status"];

    connect() {
        console.info("[relationship-graph] Controller connected", {
            element: this.element,
            hasStatusTarget: this.hasStatusTarget,
            hasWorkspaceTarget: this.hasWorkspaceTarget
        });
    }

    disconnect() {
        console.info("[relationship-graph] Controller disconnected");
    }

    fit(event) {
        event?.preventDefault();

        console.info("[relationship-graph] fit() called");

        // Support common graph visualization libraries if present.
        const graphInstance =
            this.element.__graph ||
            this.element.graph ||
            this.element._graph;

        if (graphInstance) {
            try {
                if (typeof graphInstance.fit === "function") {
                    graphInstance.fit();
                    console.info("[relationship-graph] Graph instance fit() executed");
                    this.updateStatus("Graph fitted");
                    return;
                }

                if (typeof graphInstance.zoomToFit === "function") {
                    graphInstance.zoomToFit();
                    console.info("[relationship-graph] Graph instance zoomToFit() executed");
                    this.updateStatus("Graph fitted");
                    return;
                }

                console.debug(
                    "[relationship-graph] Graph instance found, but no supported fit method",
                    graphInstance
                );
            } catch (error) {
                console.error("[relationship-graph] Graph library fit failed", error);
            }
        }

        // Fallback for an SVG-based graph.
        const svg = this.element.querySelector("svg");

        if (svg) {
            const graphGroup =
                svg.querySelector("[data-graph-content]") ||
                svg.querySelector("g");

            if (graphGroup && typeof graphGroup.getBBox === "function") {
                try {
                    const bounds = graphGroup.getBBox();

                    if (bounds.width > 0 && bounds.height > 0) {
                        const padding = 24;

                        svg.setAttribute(
                            "viewBox",
                            [
                                bounds.x - padding,
                                bounds.y - padding,
                                bounds.width + padding * 2,
                                bounds.height + padding * 2
                            ].join(" ")
                        );

                        svg.setAttribute("preserveAspectRatio", "xMidYMid meet");

                        console.info("[relationship-graph] SVG fitted", bounds);
                        this.updateStatus("Graph fitted");
                        return;
                    }
                } catch (error) {
                    console.error("[relationship-graph] SVG fitting failed", error);
                }
            }

            console.warn(
                "[relationship-graph] SVG exists, but no measurable graph content was found"
            );
            this.updateStatus("Graph content unavailable");
            return;
        }

        // No visualization is present. Do not throw an error.
        console.warn(
            "[relationship-graph] No SVG or supported graph instance found. " +
            "The current page may contain only the entity list."
        );

        this.updateStatus("No graph visualization found");
    }

    updateStatus(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = message;
        }

        console.debug("[relationship-graph] Status:", message);
    }
}