
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "container",
        "connected",
        "isolated",
        "coverage",
        "insightCount",
        "emptyState"
    ];

    static values = {
        metrics: { type: Object, default: {} }
    };

    connect() {
        this.render();
    }

    metricsValueChanged() {
        this.render();
    }

    render() {
        const metrics = this.metricsValue || {};
        const nodeCount = this.number(metrics.node_count);
        const edgeCount = this.number(metrics.edge_count);
        const connected = this.number(metrics.connected_node_count);
        const isolated = this.number(metrics.isolated_node_count);
        const coverage = nodeCount
            ? Math.round((connected / nodeCount) * 100)
            : 0;

        this.setText(this.connectedTargets, connected);
        this.setText(this.isolatedTargets, isolated);
        this.setText(this.coverageTargets, `${coverage}%`);

        const insights = [];

        if (nodeCount === 0) {
            insights.push({
                tone: "slate",
                title: "No entities yet",
                description: "Add or import entities to begin exploring the graph."
            });
        } else if (edgeCount === 0) {
            insights.push({
                tone: "amber",
                title: "No relationships found",
                description:
                    "All entities currently lack graph edges. Review the relationship " +
                    "filters, source data, and relationship import pipeline."
            });
        } else if (isolated > 0) {
            insights.push({
                tone: "orange",
                title: `${isolated} isolated entities`,
                description:
                    "Some entities have no confirmed connections. Review candidates " +
                    "and supporting evidence before creating relationships."
            });
        } else {
            insights.push({
                tone: "emerald",
                title: "Connected network",
                description:
                    "Every reported entity is connected according to the current graph payload."
            });
        }

        if (metrics.truncated === true) {
            insights.push({
                tone: "violet",
                title: "Results are limited",
                description:
                    "The returned graph was truncated. Increase the permitted query " +
                    "limit or inspect a smaller neighborhood."
            });
        }

        if (metrics.generated_at) {
            insights.push({
                tone: "sky",
                title: "Snapshot available",
                description: `Data snapshot: ${metrics.generated_at}`
            });
        }

        if (this.hasInsightCountTarget) {
            this.insightCountTarget.textContent = String(insights.length);
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = insights.length > 0;
        }

        if (!this.hasContainerTarget) return;

        this.containerTarget.replaceChildren();

        insights.forEach((insight) => {
            const card = document.createElement("article");
            card.className =
                "rounded-2xl border p-4 shadow-sm " +
                this.toneClass(insight.tone);

            const title = document.createElement("h4");
            title.className = "text-base font-black";
            title.textContent = insight.title;

            const description = document.createElement("p");
            description.className = "mt-2 text-sm leading-6";
            description.textContent = insight.description;

            card.append(title, description);
            this.containerTarget.appendChild(card);
        });
    }

    number(value) {
        const result = Number(value);
        return Number.isFinite(result) && result >= 0 ? result : 0;
    }

    setText(targets, value) {
        targets.forEach((target) => {
            target.textContent = String(value);
        });
    }

    toneClass(tone) {
        const classes = {
            slate: "border-slate-200 bg-slate-50 text-slate-700",
            amber: "border-amber-200 bg-amber-50 text-amber-900",
            orange: "border-orange-200 bg-orange-50 text-orange-900",
            emerald: "border-emerald-200 bg-emerald-50 text-emerald-900",
            violet: "border-violet-200 bg-violet-50 text-violet-900",
            sky: "border-sky-200 bg-sky-50 text-sky-900"
        };

        return classes[tone] || classes.slate;
    }

    setMetrics(metrics) {
        if (!metrics || typeof metrics !== "object" || Array.isArray(metrics)) {
            return;
        }

        this.metricsValue = metrics;
    }
}