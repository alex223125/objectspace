
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["search", "status", "row", "count", "empty"];

    connect() {
        this.filter();
    }

    filter() {
        const query = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : "";

        const selectedStatus = this.hasStatusTarget
            ? this.statusTarget.value.trim().toLowerCase()
            : "";

        let visibleCount = 0;

        this.rowTargets.forEach((row) => {
            const searchText = (
                row.dataset.searchText || row.textContent || ""
            ).toLowerCase();

            const status = (row.dataset.entityStatus || "").toLowerCase();

            const matchesQuery =
                query.length === 0 || searchText.includes(query);

            const matchesStatus =
                selectedStatus.length === 0 || status === selectedStatus;

            const visible = matchesQuery && matchesStatus;

            row.hidden = !visible;

            if (visible) {
                visibleCount += 1;
            }
        });

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `Showing ${visibleCount} of ${this.rowTargets.length} ` +
                "entities in the graph payload.";
        }

        if (this.hasEmptyTarget) {
            this.emptyTarget.classList.toggle("hidden", visibleCount !== 0);
        }
    }
}