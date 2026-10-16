
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.group("[graph-accessibility] Accessibility checks");

    try {
      const title = this.element.querySelector(
          "#relationship-graph-title"
      );

      if (!title) {
        console.warn("[graph-accessibility] Page title not found.");
      } else {
        console.log("[graph-accessibility] Page title:", title.textContent.trim());
      }

      const unlabeledButtons = Array.from(
          this.element.querySelectorAll("button")
      ).filter((button) => {
        const label = [
          button.getAttribute("aria-label"),
          button.getAttribute("title"),
          button.textContent
        ].filter(Boolean).join(" ").trim();

        return !label;
      });

      if (unlabeledButtons.length) {
        console.warn(
            "[graph-accessibility] Buttons without accessible text:",
            unlabeledButtons
        );
      }

      const inputs = Array.from(
          this.element.querySelectorAll("input, select, textarea")
      );

      const unlabeledInputs = inputs.filter((input) => {
        return !input.labels?.length &&
            !input.getAttribute("aria-label") &&
            !input.getAttribute("aria-labelledby");
      });

      if (unlabeledInputs.length) {
        console.warn(
            "[graph-accessibility] Inputs without associated labels:",
            unlabeledInputs
        );
      }

      console.log("[graph-accessibility] Checks completed.");
    } catch (error) {
      console.error("[graph-accessibility] Check failed:", error);
    } finally {
      console.groupEnd();
    }
  }

  disconnect() {
    console.log("[graph-accessibility] Disconnected");
  }
}