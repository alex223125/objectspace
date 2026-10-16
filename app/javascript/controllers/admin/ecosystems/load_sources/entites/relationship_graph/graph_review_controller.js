import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item", "status"];

  connect() {
    this.reviewed = new Map();
  }

  approve(event) {
    this.review(event.currentTarget, "approved");
  }

  reject(event) {
    this.review(event.currentTarget, "rejected");
  }

  defer(event) {
    this.review(event.currentTarget, "deferred");
  }

  review(button, decision) {
    const item = button.closest("[data-review-id]");

    if (!item) {
      this.setStatus("Cannot identify the relationship for review.");
      return;
    }

    const id = item.dataset.reviewId;

    if (!id) {
      this.setStatus("The relationship has no review identifier.");
      return;
    }

    this.reviewed.set(id, decision);
    item.dataset.reviewDecision = decision;

    this.dispatch("decision", {
      detail: { id, decision },
    });

    this.setStatus(`Relationship ${id}: ${decision}.`);
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message;
    }
  }
}
