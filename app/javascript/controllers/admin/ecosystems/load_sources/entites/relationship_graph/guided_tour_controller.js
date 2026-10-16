
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["title", "description", "progress"];

  connect() {
    console.log("[guided-tour] Connected", {
      title: this.hasTitleTarget,
      description: this.hasDescriptionTarget,
      progress: this.hasProgressTarget
    });

    this.steps = Array.from(
        this.element.querySelectorAll("[data-guided-tour-step]")
    );

    this.currentIndex = Math.max(
        0,
        this.steps.findIndex((step) => !step.hidden)
    );

    if (this.steps.length) {
      this.showStep(this.currentIndex);
    } else {
      console.info(
          "[guided-tour] No data-guided-tour-step elements found. " +
          "Navigation is safely disabled until steps are configured."
      );
    }
  }

  disconnect() {
    console.log("[guided-tour] Disconnected");
  }

  next() {
    console.log("[guided-tour] next()");

    if (!this.steps.length) {
      console.warn("[guided-tour] No configured tour steps.");
      return;
    }

    this.showStep(Math.min(
        this.currentIndex + 1,
        this.steps.length - 1
    ));
  }

  previous() {
    console.log("[guided-tour] previous()");

    if (!this.steps.length) {
      console.warn("[guided-tour] No configured tour steps.");
      return;
    }

    this.showStep(Math.max(this.currentIndex - 1, 0));
  }

  close() {
    console.log("[guided-tour] close()");

    this.element.hidden = true;
    this.element.setAttribute("aria-hidden", "true");
  }

  showStep(index) {
    if (!this.steps[index]) {
      console.warn("[guided-tour] Invalid step index:", index);
      return;
    }

    this.currentIndex = index;

    this.steps.forEach((step, i) => {
      step.hidden = i !== index;
    });

    const step = this.steps[index];
    const title = step.querySelector("[data-tour-title]");
    const description = step.querySelector("[data-tour-description]");

    if (this.hasTitleTarget && title) {
      this.titleTarget.textContent = title.textContent;
    }

    if (this.hasDescriptionTarget && description) {
      this.descriptionTarget.textContent = description.textContent;
    }

    if (this.hasProgressTarget) {
      this.progressTarget.style.width =
          `${((index + 1) / this.steps.length) * 100}%`;
    }

    console.log("[guided-tour] Showing step", {
      current: index + 1,
      total: this.steps.length,
      element: step
    });
  }
}