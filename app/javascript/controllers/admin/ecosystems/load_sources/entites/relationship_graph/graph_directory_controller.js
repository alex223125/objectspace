
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["search", "item", "resultCount", "emptyState"];

    static values = {
        total: Number,
        selectedId: String
    };

    connect() {
        this.filter();
    }

    filter() {
        const query = (this.hasSearchTarget ? this.searchTarget.value : "")
            .trim()
            .toLocaleLowerCase();

        let visible = 0;

        this.itemTargets.forEach((item) => {
            const searchableText = [
                item.dataset.name,
                item.dataset.entityId,
                item.dataset.summary,
                item.dataset.entityType,
                item.textContent
            ]
                .filter(Boolean)
                .join(" ")
                .toLocaleLowerCase();

            const matches = !query || searchableText.includes(query);

            item.hidden = !matches;

            if (matches) visible += 1;
        });

        if (this.hasResultCountTarget) {
            this.resultCountTarget.textContent =
                `${visible} of ${this.itemTargets.length} entities`;
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visible !== 0;
        }

        this.dispatch("filtered", {
            detail: { query, visible, total: this.itemTargets.length }
        });
    }

    select(event) {
        const item = event.currentTarget;
        const id = item.dataset.entityId || item.dataset.graphCanvasNodeId;

        if (!id) return;

        this.selectedIdValue = String(id);

        this.itemTargets.forEach((candidate) => {
            const candidateId =
                candidate.dataset.entityId ||
                candidate.dataset.graphCanvasNodeId;

            const selected = String(candidateId) === String(id);

            candidate.setAttribute("aria-pressed", String(selected));
            candidate.classList.toggle("is-selected", selected);
        });

        this.dispatch("selected", {
            detail: {
                id: String(id),
                name: item.dataset.name || item.textContent.trim()
            }
        });
    }

    clear() {
        if (this.hasSearchTarget) {
            this.searchTarget.value = "";
        }

        this.filter();
        this.searchTarget?.focus();
    }
}