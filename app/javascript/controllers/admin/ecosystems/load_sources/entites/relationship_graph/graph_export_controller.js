
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        console.log("[graph-export] Connected", this.element);
    }

    download() {
        console.group("[graph-export] download()");

        try {
            const source = document.querySelector(
                "[data-graph-export-target='source'], " +
                "#graph-export-data"
            );

            let data;

            if (source) {
                const raw = source.tagName === "SCRIPT"
                    ? source.textContent
                    : source.value;

                data = JSON.parse(raw);
                console.log("[graph-export] Using supplied JSON payload.");
            } else {
                const nodes = Array.from(
                    document.querySelectorAll("[data-graph-node-id]")
                ).map((element) => ({
                    id: element.getAttribute("data-graph-node-id"),
                    text: element.textContent.trim()
                }));

                data = {
                    export_type: "rendered_graph_diagnostic",
                    warning:
                        "DOM snapshot only; this is not the complete service response.",
                    nodes,
                    edges: [],
                    exported_at: new Date().toISOString()
                };

                console.warn(
                    "[graph-export] No JSON payload found. " +
                    "Exporting a DOM diagnostic snapshot; edges are not reconstructed."
                );
            }

            const blob = new Blob(
                [JSON.stringify(data, null, 2)],
                { type: "application/json;charset=utf-8" }
            );

            const url = URL.createObjectURL(blob);
            const link = document.createElement("a");

            link.href = url;
            link.download = "relationship-graph.json";
            link.style.display = "none";

            document.body.appendChild(link);
            link.click();
            link.remove();

            URL.revokeObjectURL(url);

            console.log("[graph-export] Download initiated.", {
                bytes: blob.size
            });
        } catch (error) {
            console.error("[graph-export] Download failed:", error);
        } finally {
            console.groupEnd();
        }
    }

    disconnect() {
        console.log("[graph-export] Disconnected");
    }
}