
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status", "lastUpdated", "refreshButton"]

  static values = {
    url: String,
    interval: { type: Number, default: 30000 },
    enabled: { type: Boolean, default: false }
  }

  connect() {
    this.timer = null
    this.abortController = null
    this.refreshing = false
    this.stopped = false

    this.onVisibilityChange = () => {
      if (document.hidden) {
        this.stopPolling()
      } else if (this.enabledValue) {
        this.startPolling()
      }
    }

    document.addEventListener(
        "visibilitychange",
        this.onVisibilityChange
    )

    if (this.enabledValue) this.startPolling()
  }

  disconnect() {
    this.stopped = true
    this.stopPolling()

    document.removeEventListener(
        "visibilitychange",
        this.onVisibilityChange
    )
  }

  startPolling() {
    this.stopPolling()

    if (
        !this.enabledValue ||
        !this.hasUrlValue ||
        !this.urlValue ||
        document.hidden ||
        this.stopped
    ) {
      return
    }

    this.refresh()

    this.timer = window.setInterval(
        () => this.refresh(),
        Math.max(10000, this.intervalValue)
    )
  }

  stopPolling() {
    if (this.timer) {
      window.clearInterval(this.timer)
      this.timer = null
    }

    this.abortController?.abort()
    this.abortController = null
  }

  async refresh() {
    if (
        this.refreshing ||
        this.stopped ||
        !this.hasUrlValue ||
        !this.urlValue
    ) {
      return
    }

    this.refreshing = true
    this.abortController = new AbortController()

    if (this.hasRefreshButtonTarget) {
      this.refreshButtonTarget.disabled = true
    }

    this.announce("Checking for graph updates…")

    try {
      const response = await fetch(this.urlValue, {
        method: "GET",
        credentials: "same-origin",
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        },
        signal: this.abortController.signal
      })

      if (!response.ok) {
        throw new Error(`Update request failed (${response.status}).`)
      }

      const payload = await response.json()

      if (!Array.isArray(payload.nodes) || !Array.isArray(payload.edges)) {
        throw new Error("The update response has an unexpected graph format.")
      }

      this.element.dispatchEvent(
          new CustomEvent("relationship-graph:updated", {
            bubbles: true,
            detail: { data: payload }
          })
      )

      const timestamp = new Date()

      if (this.hasLastUpdatedTarget) {
        this.lastUpdatedTarget.textContent =
            `Checked ${timestamp.toLocaleTimeString()}`
      }

      this.announce("Graph data refreshed.")
    } catch (error) {
      if (error.name !== "AbortError") {
        this.announce(error.message || "Unable to refresh graph data.")
      }
    } finally {
      this.refreshing = false
      this.abortController = null

      if (this.hasRefreshButtonTarget) {
        this.refreshButtonTarget.disabled = false
      }
    }
  }

  enable() {
    this.enabledValue = true
    this.stopped = false
    this.startPolling()
  }

  disable() {
    this.enabledValue = false
    this.stopPolling()
    this.announce("Automatic graph updates paused.")
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}