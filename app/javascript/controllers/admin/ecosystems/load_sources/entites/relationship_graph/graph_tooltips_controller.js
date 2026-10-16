
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("[graph-tooltips] Connected");

    let count = 0;

    this.element.querySelectorAll("[data-tooltip]").forEach((node) => {
      const message = node.getAttribute("data-tooltip");

      if (message && !node.hasAttribute("title")) {
        node.setAttribute("title", message);
        count += 1;
      }
    });

    console.log("[graph-tooltips] Native titles added:", count);
  }

  disconnect() {
    console.log("[graph-tooltips] Disconnected");
  }
}