
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    console.log("[graph-search] Connected", {
      inputTarget: this.hasInputTarget
    });

    if (!this.hasInputTarget) {
      console.warn(
          "[graph-search] Missing data-graph-search-target='input'."
      );
    }
  }

  disconnect() {
    console.log("[graph-search] Disconnected");
  }

  search(event) {
    const query = (
        event?.currentTarget?.value ??
        (this.hasInputTarget ? this.inputTarget.value : "")
    ).trim().toLowerCase();

    const nodes = this.getNodes();
    let visible = 0;

    nodes.forEach((node) => {
      const matches = !query ||
          node.textContent.toLowerCase().includes(query);

      node.hidden = !matches;

      if (matches) visible += 1;
    });

    console.log("[graph-search] Search completed", {
      query,
      total: nodes.length,
      visible,
      hidden: nodes.length - visible
    });

    this.element.dispatchEvent(
        new CustomEvent("graph-search:updated", {
          bubbles: true,
          detail: { query, total: nodes.length, visible }
        })
    );
  }

  clear() {
    console.log("[graph-search] clear()");

    if (this.hasInputTarget) {
      this.inputTarget.value = "";
    }

    this.getNodes().forEach((node) => {
      node.hidden = false;
    });

    console.log("[graph-search] Search cleared; all nodes restored.");
  }

  getNodes() {
    return Array.from(
        this.element.querySelectorAll("[data-graph-node-id]")
    );
  }
}