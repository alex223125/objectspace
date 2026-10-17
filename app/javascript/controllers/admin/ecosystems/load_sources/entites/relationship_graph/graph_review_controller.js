
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "item",
    "decision",
    "reason",
    "submit",
    "status",
    "confirmation"
  ]

  static values = {
    url: String,
    csrf: String
  }

  connect() {
    this.pendingDecision = null
    this.busy = false
  }

  prepare(event) {
    const button = event.currentTarget
    const item = button.closest("[data-review-id]")

    if (!item) {
      this.announce("Unable to identify the relationship for review.")
      return
    }

    const decision = button.dataset.reviewDecision

    if (!["approve", "reject", "request_changes"].includes(decision)) {
      this.announce("Unsupported review decision.")
      return
    }

    const id = item.dataset.reviewId

    if (!id) {
      this.announce("The relationship review ID is missing.")
      return
    }

    this.pendingDecision = {
      id,
      decision,
      item,
      button
    }

    if (this.hasConfirmationTarget) {
      this.confirmationTarget.hidden = false
      this.confirmationTarget.querySelector(
          "[data-review-confirmation-message]"
      )?.replaceChildren(
          document.createTextNode(
              `Confirm ${decision.replace("_", " ")} for relationship ${id}?`
          )
      )

      this.confirmationTarget.querySelector("button")?.focus()
    } else {
      this.announce(
          "Review decision prepared. Add a confirmation panel before enabling submission."
      )
    }
  }

  cancel() {
    this.pendingDecision = null

    if (this.hasConfirmationTarget) {
      this.confirmationTarget.hidden = true
    }

    this.announce("Review decision cancelled.")
  }

  async confirm() {
    if (this.busy || !this.pendingDecision) return

    if (!this.hasUrlValue || !this.urlValue) {
      this.announce("Review endpoint is not configured.")
      return
    }

    const { id, decision, item, button } = this.pendingDecision
    const reason = this.hasReasonTarget
        ? this.reasonTarget.value.trim()
        : ""

    this.busy = true
    this.setButtonsDisabled(true)

    try {
      const response = await fetch(this.reviewUrl(id), {
        method: "PATCH",
        credentials: "same-origin",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "X-Requested-With": "XMLHttpRequest"
        },
        body: JSON.stringify({
          review: {
            decision,
            reason
          }
        })
      })

      const payload = await response.json().catch(() => ({}))

      if (!response.ok) {
        throw new Error(
            payload.error ||
            payload.message ||
            `Review failed with HTTP ${response.status}.`
        )
      }

      item.dataset.reviewStatus = decision

      item.dispatchEvent(new CustomEvent(
          "relationship-graph:reviewed",
          {
            bubbles: true,
            detail: {
              id,
              decision,
              response: payload
            }
          }
      ))

      if (this.hasConfirmationTarget) {
        this.confirmationTarget.hidden = true
      }

      if (this.hasReasonTarget) {
        this.reasonTarget.value = ""
      }

      this.pendingDecision = null

      this.announce(`Relationship ${id}: ${decision} completed.`)

      button?.focus()
    } catch (error) {
      this.announce(
          error.message || "Unable to submit the review."
      )
    } finally {
      this.busy = false
      this.setButtonsDisabled(false)
    }
  }

  reviewUrl(id) {
    const base = this.urlValue.replace(/\/+$/, "")

    // The ID is encoded so it cannot introduce URL path segments.
    return `${base}/${encodeURIComponent(id)}`
  }

  csrfToken() {
    if (this.hasCsrfValue && this.csrfValue) {
      return this.csrfValue
    }

    return document.querySelector(
        'meta[name="csrf-token"]'
    )?.content || ""
  }

  setButtonsDisabled(disabled) {
    this.element.querySelectorAll(
        "[data-review-decision], [data-action~='graph-review#confirm']"
    ).forEach((button) => {
      button.disabled = disabled
    })
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}