
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["tab", "panel", "status"]

    static values = {
        activeTab: { type: String, default: "overview" }
    }

    connect() {
        this.activate(this.activeTabValue, false)
    }

    select(event) {
        const tab = event.currentTarget
        const name = tab.dataset.workspaceTab

        if (!name) return

        event.preventDefault()
        this.activate(name)
    }

    activate(name, announce = true) {
        const matchingPanel = this.panelTargets.some(
            panel => panel.dataset.workspacePanel === name
        )

        if (!matchingPanel) return

        this.activeTabValue = name

        this.tabTargets.forEach(tab => {
            const active = tab.dataset.workspaceTab === name

            tab.setAttribute("aria-selected", String(active))
            tab.setAttribute("tabindex", active ? "0" : "-1")
            tab.classList.toggle("is-active", active)
        })

        this.panelTargets.forEach(panel => {
            const active = panel.dataset.workspacePanel === name

            panel.hidden = !active
            panel.classList.toggle("is-active", active)
        })

        if (this.hasStatusTarget) {
            this.statusTarget.textContent = `Current workspace section: ${name}`
        }

        if (announce) {
            this.dispatch("section-changed", {
                detail: { section: name }
            })
        }
    }

    next(event) {
        event?.preventDefault()

        const currentIndex = this.tabTargets.findIndex(
            tab => tab.dataset.workspaceTab === this.activeTabValue
        )

        if (currentIndex < 0 || this.tabTargets.length === 0) return

        const nextIndex = (currentIndex + 1) % this.tabTargets.length
        this.activate(this.tabTargets[nextIndex].dataset.workspaceTab)
        this.tabTargets[nextIndex].focus()
    }

    previous(event) {
        event?.preventDefault()

        const currentIndex = this.tabTargets.findIndex(
            tab => tab.dataset.workspaceTab === this.activeTabValue
        )

        if (currentIndex < 0 || this.tabTargets.length === 0) return

        const previousIndex =
            (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length

        this.activate(this.tabTargets[previousIndex].dataset.workspaceTab)
        this.tabTargets[previousIndex].focus()
    }
}