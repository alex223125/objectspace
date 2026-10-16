import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "status", "form", "clearButton"]

  connect() {
    this.syncClearButton()
  }

  submit() {
    if (this.hasFormTarget) this.formTarget.requestSubmit()
  }

  clear() {
    if (this.hasQueryTarget) this.queryTarget.value = ""
    if (this.hasStatusTarget) this.statusTarget.value = ""

    if (this.hasFormTarget) this.formTarget.requestSubmit()
  }

  syncClearButton() {
    if (!this.hasClearButtonTarget) return

    const hasQuery =
      this.hasQueryTarget && this.queryTarget.value.trim().length > 0

    const hasStatus =
      this.hasStatusTarget && this.statusTarget.value.length > 0

    this.clearButtonTarget.hidden = !(hasQuery || hasStatus)
  }
}
