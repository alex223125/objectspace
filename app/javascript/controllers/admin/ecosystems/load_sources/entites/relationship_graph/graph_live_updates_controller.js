import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["status", "timestamp"];

  connect() {
    this.setStatus("Live updates are not connected.");
  }

  announce(event) {
    const detail = event.detail || {};

    this.setStatus(
      detail.message || "The graph received an update."
    );

    if (this.hasTimestampTarget) {
      this.timestampTarget.textContent =
        new Date().toLocaleTimeString();
    }
  }

  connected() {
    this.setStatus("Live update connection established.");
  }

  disconnected() {
    this.setStatus("Live update connection disconnected.");
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }
}
