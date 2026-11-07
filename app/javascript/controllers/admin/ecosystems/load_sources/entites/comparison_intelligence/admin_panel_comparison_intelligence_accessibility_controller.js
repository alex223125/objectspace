import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    largeText: { type: Boolean, default: false },
    highContrast: { type: Boolean, default: false },
    reducedMotion: { type: Boolean, default: false }
  }

  connect() {
    this.applySettings()
  }

  toggleLargeText() {
    this.largeTextValue = !this.largeTextValue
  }

  toggleHighContrast() {
    this.highContrastValue = !this.highContrastValue
  }

  toggleReducedMotion() {
    this.reducedMotionValue = !this.reducedMotionValue
  }

  largeTextValueChanged() { this.applySettings() }
  highContrastValueChanged() { this.applySettings() }
  reducedMotionValueChanged() { this.applySettings() }

  applySettings() {
    this.element.classList.toggle("ci-large-text", this.largeTextValue)
    this.element.classList.toggle("ci-high-contrast", this.highContrastValue)
    this.element.classList.toggle("ci-reduced-motion", this.reducedMotionValue)
  }
}
