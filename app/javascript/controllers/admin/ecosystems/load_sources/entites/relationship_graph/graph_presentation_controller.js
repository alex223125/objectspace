
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("[graph-presentation] Connected");

    const savedMode = this.readSavedMode();
    const checked = this.element.querySelector(
        'input[name="graph_presentation_mode"]:checked'
    );

    this.applyMode(checked?.value || savedMode || "standard");
  }

  changeMode(event) {
    const mode = event?.currentTarget?.value;

    console.log("[graph-presentation] changeMode()", { mode });

    if (!["standard", "compact", "presentation"].includes(mode)) {
      console.warn("[graph-presentation] Unsupported mode:", mode);
      return;
    }

    this.applyMode(mode);
  }

  applyMode(mode) {
    const workspace = document.querySelector(
        "[data-relationship-graph-target='workspace']"
    );

    if (!workspace) {
      console.warn("[graph-presentation] Workspace not found.");
      return;
    }

    workspace.classList.remove(
        "graph-mode-standard",
        "graph-mode-compact",
        "graph-mode-presentation"
    );

    workspace.classList.add(`graph-mode-${mode}`);

    this.element.querySelectorAll(
        'input[name="graph_presentation_mode"]'
    ).forEach((input) => {
      input.checked = input.value === mode;
    });

    try {
      window.localStorage.setItem("graph-presentation-mode", mode);
    } catch (error) {
      console.warn(
          "[graph-presentation] Could not save preference:",
          error
      );
    }

    console.log("[graph-presentation] Applied mode:", mode);
  }

  readSavedMode() {
    try {
      const value = window.localStorage.getItem(
          "graph-presentation-mode"
      );

      return ["standard", "compact", "presentation"].includes(value)
          ? value
          : null;
    } catch (error) {
      console.warn(
          "[graph-presentation] Could not read preference:",
          error
      );
      return null;
    }
  }
}