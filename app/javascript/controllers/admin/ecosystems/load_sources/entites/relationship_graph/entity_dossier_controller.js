import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "content", "status"];

  connect() {
    this.selectedEntityId = null;
  }

  show(event) {
    const entity = event.currentTarget;
    const entityId = entity.dataset.entityId;

    if (!entityId) {
      this.setStatus("This item has no entity identifier.");
      return;
    }

    this.selectedEntityId = entityId;

    if (this.hasPanelTarget) {
      this.panelTarget.hidden = false;
    }

    this.dispatch("requested", {
      detail: { entityId },
    });

    this.setStatus(`Entity ${entityId} selected.`);
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.hidden = true;
    }

    this.selectedEntityId = null;
    this.setStatus("Entity details closed.");
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }
}
