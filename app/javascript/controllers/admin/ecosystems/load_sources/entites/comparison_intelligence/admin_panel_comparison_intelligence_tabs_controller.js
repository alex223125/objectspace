import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.activateInitialTab()
  }

  activateInitialTab() {
    const selected = this.tabTargets.find(
      tab => tab.getAttribute("aria-selected") === "true"
    ) || this.tabTargets[0]
    if (selected) this.activate(selected)
  }

  select(event) {
    event.preventDefault()
    this.activate(event.currentTarget)
  }

  activate(tab) {
    const panelId = tab.getAttribute("aria-controls")
    this.tabTargets.forEach(item => {
      const active = item === tab
      item.setAttribute("aria-selected", String(active))
      item.setAttribute("tabindex", active ? "0" : "-1")
    })
    this.panelTargets.forEach(panel => {
      panel.hidden = panel.id !== panelId
    })
  }

  keydown(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    if (index < 0) return

    let next = index
    if (event.key === "ArrowRight" || event.key === "ArrowDown") next++
    else if (event.key === "ArrowLeft" || event.key === "ArrowUp") next--
    else if (event.key === "Home") next = 0
    else if (event.key === "End") next = this.tabTargets.length - 1
    else return

    event.preventDefault()
    next = (next + this.tabTargets.length) % this.tabTargets.length
    this.tabTargets[next]?.focus()
    this.activate(this.tabTargets[next])
  }
}
