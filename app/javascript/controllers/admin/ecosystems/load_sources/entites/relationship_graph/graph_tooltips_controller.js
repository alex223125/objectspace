
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tooltip"]

  connect() {
    this.activeElement = null
    this.tooltipElement = this.hasTooltipTarget
        ? this.tooltipTarget
        : this.createTooltip()

    this.tooltipElement.hidden = true

    this.onPointerOver = this.onPointerOver.bind(this)
    this.onPointerOut = this.onPointerOut.bind(this)
    this.onFocusIn = this.onFocusIn.bind(this)
    this.onFocusOut = this.onFocusOut.bind(this)
    this.onKeydown = this.onKeydown.bind(this)

    this.element.addEventListener("pointerover", this.onPointerOver)
    this.element.addEventListener("pointerout", this.onPointerOut)
    this.element.addEventListener("focusin", this.onFocusIn)
    this.element.addEventListener("focusout", this.onFocusOut)
    this.element.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    this.element.removeEventListener("pointerover", this.onPointerOver)
    this.element.removeEventListener("pointerout", this.onPointerOut)
    this.element.removeEventListener("focusin", this.onFocusIn)
    this.element.removeEventListener("focusout", this.onFocusOut)
    this.element.removeEventListener("keydown", this.onKeydown)

    this.tooltipElement?.remove()
    this.tooltipElement = null
  }

  createTooltip() {
    const tooltip = document.createElement("div")

    tooltip.id = `graph-tooltip-${Math.random().toString(36).slice(2, 10)}`
    tooltip.className = [
      "fixed z-[100] max-w-sm rounded-2xl border-2 border-orange-200",
      "bg-white p-4 text-sm text-slate-700 shadow-xl shadow-orange-100/60",
      "pointer-events-none"
    ].join(" ")

    tooltip.setAttribute("role", "tooltip")
    tooltip.hidden = true

    document.body.append(tooltip)
    return tooltip
  }

  onPointerOver(event) {
    const target = this.findTooltipTarget(event.target)
    if (!target) return

    if (event.relatedTarget && target.contains(event.relatedTarget)) {
      return
    }

    this.show(target, event.clientX, event.clientY)
  }

  onPointerOut(event) {
    const target = this.findTooltipTarget(event.target)
    if (!target) return

    if (event.relatedTarget && target.contains(event.relatedTarget)) {
      return
    }

    if (this.activeElement === target) {
      this.hide()
    }
  }

  onFocusIn(event) {
    const target = this.findTooltipTarget(event.target)
    if (!target) return

    const rect = target.getBoundingClientRect()

    this.show(
        target,
        rect.left + rect.width / 2,
        rect.bottom
    )
  }

  onFocusOut(event) {
    const target = this.findTooltipTarget(event.target)
    if (target && this.activeElement === target) {
      this.hide()
    }
  }

  onKeydown(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }

  findTooltipTarget(element) {
    if (!(element instanceof Element)) return null

    return element.closest(
        "[data-graph-tooltip], [data-node-id], [data-edge-id]"
    )
  }

  show(target, x, y) {
    const details = this.readDetails(target)

    if (!details.title && !details.description) return

    this.activeElement = target
    this.tooltipElement.replaceChildren()

    const heading = document.createElement("p")
    heading.className = "break-words text-base font-black text-orange-800"
    heading.textContent = details.title || "Graph information"

    this.tooltipElement.append(heading)

    if (details.description) {
      const description = document.createElement("p")
      description.className = "mt-2 break-words text-sm leading-6 text-slate-700"
      description.textContent = details.description
      this.tooltipElement.append(description)
    }

    if (details.metadata.length > 0) {
      const list = document.createElement("dl")
      list.className = "mt-3 space-y-2"

      details.metadata.forEach(([label, value]) => {
        const row = document.createElement("div")
        row.className = "flex flex-wrap gap-x-2"

        const term = document.createElement("dt")
        term.className = "font-bold text-slate-500"
        term.textContent = `${label}:`

        const detail = document.createElement("dd")
        detail.className = "break-words text-slate-800"
        detail.textContent = value

        row.append(term, detail)
        list.append(row)
      })

      this.tooltipElement.append(list)
    }

    this.tooltipElement.hidden = false

    if (!target.hasAttribute("aria-describedby")) {
      target.dataset.graphTooltipPreviousDescribedby =
          target.getAttribute("aria-describedby") || ""
    }

    const previous = target.dataset.graphTooltipPreviousDescribedby
        .split(/\s+/)
        .filter(Boolean)

    if (!previous.includes(this.tooltipElement.id)) {
      previous.push(this.tooltipElement.id)
    }

    target.setAttribute("aria-describedby", previous.join(" "))

    this.position(x, y)
  }

  readDetails(target) {
    const explicitTitle = target.dataset.graphTooltipTitle
    const explicitDescription = target.dataset.graphTooltipDescription

    const title = explicitTitle ||
        target.getAttribute("aria-label") ||
        target.querySelector("title")?.textContent?.trim() ||
        target.querySelector("[data-entity-name]")?.textContent?.trim() ||
        target.querySelector("text")?.textContent?.trim() ||
        ""

    const description = explicitDescription ||
        target.dataset.graphTooltip ||
        target.dataset.summary ||
        target.getAttribute("data-description") ||
        ""

    const metadata = []

    if (target.dataset.nodeId) {
      metadata.push(["Entity ID", target.dataset.nodeId])
    }

    if (target.dataset.edgeId) {
      metadata.push(["Relationship ID", target.dataset.edgeId])
    }

    if (target.dataset.status) {
      metadata.push(["Status", target.dataset.status])
    }

    if (target.dataset.entityType) {
      metadata.push(["Type", target.dataset.entityType])
    }

    return { title, description, metadata }
  }

  position(x, y) {
    const margin = 12
    const offset = 16
    const tooltip = this.tooltipElement

    tooltip.style.left = "0px"
    tooltip.style.top = "0px"

    const rect = tooltip.getBoundingClientRect()

    let left = x + offset
    let top = y + offset

    if (left + rect.width + margin > window.innerWidth) {
      left = x - rect.width - offset
    }

    if (top + rect.height + margin > window.innerHeight) {
      top = y - rect.height - offset
    }

    left = Math.max(margin, Math.min(left, window.innerWidth - rect.width - margin))
    top = Math.max(margin, Math.min(top, window.innerHeight - rect.height - margin))

    tooltip.style.left = `${left}px`
    tooltip.style.top = `${top}px`
  }

  hide() {
    if (!this.tooltipElement) return

    const target = this.activeElement

    if (target) {
      const previous = (target.dataset.graphTooltipPreviousDescribedby || "")
          .split(/\s+/)
          .filter(Boolean)
          .filter((id) => id !== this.tooltipElement.id)

      if (previous.length > 0) {
        target.setAttribute("aria-describedby", previous.join(" "))
      } else {
        target.removeAttribute("aria-describedby")
      }

      delete target.dataset.graphTooltipPreviousDescribedby
    }

    this.tooltipElement.hidden = true
    this.activeElement = null
  }
}