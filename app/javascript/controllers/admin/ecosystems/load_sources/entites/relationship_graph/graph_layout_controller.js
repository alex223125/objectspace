import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["canvas", "item", "status"];

  static values = {
    layout: { type: String, default: "standard" },
  };

  connect() {
    this.apply();
  }

  change(event) {
    const requested = event.currentTarget.value;
    const allowed = ["standard", "compact", "hierarchical", "radial"];

    if (!allowed.includes(requested)) {
      this.setStatus("Unsupported layout.");
      return;
    }

    this.layoutValue = requested;
    this.apply();
  }

  apply() {
    this.element.dataset.graphLayout = this.layoutValue;

    if (this.hasCanvasTarget) {
      this.canvasTarget.dataset.layout = this.layoutValue;
    }

    this.dispatch("layout-changed", {
      detail: { layout: this.layoutValue },
    });

    this.setStatus(`Layout selected: ${this.layoutValue}.`);
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }
}
