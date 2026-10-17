
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "list",
        "emptyState",
        "count",
        "coverage",
        "template"
    ];

    static values = {
        evidence: { type: Array, default: [] }
    };

    connect() {
        this.render();
    }

    evidenceValueChanged() {
        this.render();
    }

    render() {
        const evidence = this.evidenceValue || [];

        if (this.hasCountTarget) {
            this.countTarget.textContent = String(evidence.length);
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = evidence.length > 0;
        }

        if (this.hasListTarget) {
            this.listTarget.replaceChildren();

            evidence.forEach((record) => {
                this.listTarget.appendChild(this.buildEvidence(record));
            });
        }

        if (this.hasCoverageTarget) {
            const verified = evidence.filter(
                (record) => record.verified === true
            ).length;

            const percentage = evidence.length
                ? Math.round((verified / evidence.length) * 100)
                : 0;

            this.coverageTarget.textContent = `${percentage}% verified`;
            this.coverageTarget.setAttribute("aria-valuenow", String(percentage));
        }
    }

    buildEvidence(record) {
        const article = document.createElement("article");
        article.className =
            "rounded-2xl border border-orange-100 bg-gradient-to-br " +
            "from-white to-orange-50/40 p-4 shadow-sm";

        const title = document.createElement("h4");
        title.className = "text-base font-bold text-slate-800";
        title.textContent = record.title || "Untitled evidence";

        const description = document.createElement("p");
        description.className = "mt-2 text-sm leading-6 text-slate-600";
        description.textContent = record.description || "No description provided.";

        const status = document.createElement("span");
        status.className =
            "mt-3 inline-flex rounded-full border px-3 py-1 text-xs font-bold " +
            (record.verified
                ? "border-emerald-200 bg-emerald-50 text-emerald-700"
                : "border-amber-200 bg-amber-50 text-amber-700");

        status.textContent = record.verified ? "Verified" : "Needs verification";

        article.append(title, description, status);

        if (record.sourceUrl) {
            try {
                const url = new URL(record.sourceUrl, window.location.origin);

                if (["http:", "https:"].includes(url.protocol)) {
                    const link = document.createElement("a");
                    link.className =
                        "mt-3 block text-sm font-bold text-orange-700 underline " +
                        "decoration-orange-300 underline-offset-4 hover:text-orange-900";
                    link.href = url.href;
                    link.target = "_blank";
                    link.rel = "noopener noreferrer";
                    link.textContent = "Open source ↗";
                    article.appendChild(link);
                }
            } catch {
                // Ignore malformed source URLs.
            }
        }

        return article;
    }

    setEvidence(records) {
        if (!Array.isArray(records)) return;

        this.evidenceValue = records;
    }
}