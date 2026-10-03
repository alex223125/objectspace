import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "from",
    "to",
    "submit"
  ]

  connect() {
    this.validateSelection()
  }

  change() {
    this.validateSelection()
  }

  swap() {
    if (!this.hasFromTarget || !this.hasToTarget) {
      return
    }

    const fromValue = this.fromTarget.value
    const toValue = this.toTarget.value

    this.fromTarget.value = toValue
    this.toTarget.value = fromValue

    this.validateSelection()
  }

  validateSelection() {
    if (!this.hasFromTarget || !this.hasToTarget) {
      return
    }

    const fromValue = this.fromTarget.value
    const toValue = this.toTarget.value

    const bothSelected =
      fromValue !== "" &&
      toValue !== ""

    const differentVersions =
      fromValue !== toValue

    const valid =
      bothSelected &&
      differentVersions

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !valid
    }

    this.updateInvalidState(
      this.fromTarget,
      bothSelected && !differentVersions
    )

    this.updateInvalidState(
      this.toTarget,
      bothSelected && !differentVersions
    )
  }

  updateInvalidState(element, invalid) {
    element.setAttribute(
      "aria-invalid",
      invalid ? "true" : "false"
    )

    const field =
      element.closest(
        "[data-version-selector-field]"
      )

    if (field) {
      field.classList.toggle(
        "entity-comparison__version-field--invalid",
        invalid
      )
    }
  }
}
