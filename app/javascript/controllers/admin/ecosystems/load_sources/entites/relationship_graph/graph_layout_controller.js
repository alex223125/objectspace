
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["svg", "spacing", "status"]

  static values = {
    width: { type: Number, default: 1000 },
    height: { type: Number, default: 650 },
    scale: { type: Number, default: 1 }
  }

  connect() {
    this.defaultViewBox = `0 0 ${this.widthValue} ${this.heightValue}`
    this.currentScale = this.scaleValue
    this.applyViewBox()
  }

  fit() {
    if (!this.hasSvgTarget) return

    this.currentScale = 1
    this.applyViewBox()
    this.announce("Graph fitted to the available view.")
  }

  zoomIn() {
    this.currentScale = Math.min(this.currentScale * 1.2, 3)
    this.applyViewBox()
    this.announce(`Zoom ${Math.round(this.currentScale * 100)} percent.`)
  }

  zoomOut() {
    this.currentScale = Math.max(this.currentScale / 1.2, 0.4)
    this.applyViewBox()
    this.announce(`Zoom ${Math.round(this.currentScale * 100)} percent.`)
  }

  reset() {
    this.currentScale = 1
    this.applyViewBox()
    this.announce("View reset.")
  }

  changeSpacing(event) {
    if (!this.hasSvgTarget) return

    const spacing = Number(event.currentTarget.value)
    if (!Number.isFinite(spacing)) return

    this.element.style.setProperty(
        "--graph-node-spacing",
        `${Math.max(20, Math.min(spacing, 240))}px`
    )

    this.announce("Node spacing preference updated.")
  }

  applyViewBox() {
    if (!this.hasSvgTarget) return

    const scale = this.currentScale
    const width = this.widthValue / scale
    const height = this.heightValue / scale
    const x = (this.widthValue - width) / 2
    const y = (this.heightValue - height) / 2

    this.svgTarget.setAttribute(
        "viewBox",
        `${x} ${y} ${width} ${height}`
    )

    this.svgTarget.setAttribute("preserveAspectRatio", "xMidYMid meet")
  }

  announce(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}