import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value", "status"];

  connect() {
    this.refresh();
  }

  refresh() {
    let count = 0;

    this.valueTargets.forEach((element) => {
      const raw = element.dataset.metricValue;

      if (raw === undefined || raw.trim() === "") {
        element.textContent = "Not available";
        return;
      }

      const value = Number(raw);

      if (!Number.isFinite(value)) {
        element.textContent = "Not available";
        return;
      }

      element.textContent = new Intl.NumberFormat().format(value);
      count += 1;
    });

    if (this.hasStatusTarget) {
      this.statusTarget.textContent =
        `${count} graph metrics displayed.`;
    }

    this.dispatch("refreshed", {
      detail: { displayedMetrics: count },
    });
  }
}
