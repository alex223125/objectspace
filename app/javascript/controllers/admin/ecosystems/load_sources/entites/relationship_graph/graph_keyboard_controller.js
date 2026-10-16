
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("[graph-keyboard] Connected");
    this.boundKeydown = this.handleKeydown.bind(this);

    document.addEventListener("keydown", this.boundKeydown);
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown);
    console.log("[graph-keyboard] Disconnected");
  }

  handleKeydown(event) {
    if (event.defaultPrevented || event.altKey ||
        event.ctrlKey || event.metaKey) {
      return;
    }

    const target = event.target;

    if (
        target instanceof HTMLElement &&
        (target.isContentEditable ||
            ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName))
    ) {
      return;
    }

    if (event.key === "/" && !event.shiftKey) {
      const input = document.getElementById("graph-search");

      if (input) {
        event.preventDefault();
        input.focus();
        console.log("[graph-keyboard] Focused graph search.");
      } else {
        console.warn("[graph-keyboard] #graph-search not found.");
      }
    }

    if (event.key.toLowerCase() === "f") {
      const button = document.querySelector(
          '[data-action~="click->relationship-graph#fit"]'
      );

      if (button) {
        event.preventDefault();
        button.click();
        console.log("[graph-keyboard] Triggered fit action.");
      } else {
        console.warn("[graph-keyboard] Fit button not found.");
      }
    }
  }
}