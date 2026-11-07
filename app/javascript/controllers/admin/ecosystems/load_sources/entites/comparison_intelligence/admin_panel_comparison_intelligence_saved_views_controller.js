
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["name", "select", "status", "filterForm"]

    static values = {
        storageKey: {
            type: String,
            default: "objectspace-comparison-intelligence-saved-views"
        }
    }

    connect() {
        this.refresh()
    }

    save(event) {
        event?.preventDefault()

        const name = this.hasNameTarget
            ? this.nameTarget.value.trim()
            : ""

        if (!name) {
            this.setStatus("Enter a name for this saved view.")
            this.nameTarget?.focus()
            return
        }

        const views = this.readViews()
        const filters = this.readFilters()

        const existingIndex = views.findIndex(
            view => view.name.toLocaleLowerCase() === name.toLocaleLowerCase()
        )

        const view = {
            id: this.createId(),
            name,
            filters,
            updatedAt: new Date().toISOString()
        }

        if (existingIndex >= 0) {
            view.id = views[existingIndex].id
            views[existingIndex] = view
        } else {
            views.push(view)
        }

        if (!this.writeViews(views)) return

        this.refresh(view.id)
        this.setStatus(`Saved view "${name}".`)
    }

    apply(event) {
        event?.preventDefault()

        if (!this.hasSelectTarget || !this.selectTarget.value) {
            this.setStatus("Select a saved view first.")
            return
        }

        const view = this.readViews().find(
            item => item.id === this.selectTarget.value
        )

        if (!view) {
            this.setStatus("That saved view is no longer available.")
            this.refresh()
            return
        }

        if (this.hasFilterFormTarget) {
            this.applyFilters(this.filterFormTarget, view.filters || {})
        }

        this.dispatch("applied", {
            detail: { id: view.id, name: view.name, filters: view.filters || {} }
        })

        this.setStatus(`Applied saved view "${view.name}".`)
    }

    remove(event) {
        event?.preventDefault()

        if (!this.hasSelectTarget || !this.selectTarget.value) {
            this.setStatus("Select a saved view to delete.")
            return
        }

        const id = this.selectTarget.value
        const views = this.readViews()
        const view = views.find(item => item.id === id)

        if (!view) {
            this.setStatus("That saved view is no longer available.")
            this.refresh()
            return
        }

        if (!this.writeViews(views.filter(item => item.id !== id))) return

        this.refresh()
        this.setStatus(`Deleted saved view "${view.name}".`)
    }

    refresh(selectedId = "") {
        if (!this.hasSelectTarget) return

        const previous = selectedId || this.selectTarget.value
        const views = this.readViews()

        this.selectTarget.replaceChildren()

        const placeholder = document.createElement("option")
        placeholder.value = ""
        placeholder.textContent = "Choose a saved view"
        this.selectTarget.append(placeholder)

        views.forEach(view => {
            const option = document.createElement("option")
            option.value = view.id
            option.textContent = view.name
            this.selectTarget.append(option)
        })

        if (views.some(view => view.id === previous)) {
            this.selectTarget.value = previous
        }
    }

    readFilters() {
        if (!this.hasFilterFormTarget) return {}

        const filters = {}

        new FormData(this.filterFormTarget).forEach((value, key) => {
            if (typeof value !== "string") return

            if (Object.prototype.hasOwnProperty.call(filters, key)) {
                const previous = filters[key]
                filters[key] = Array.isArray(previous)
                    ? [...previous, value]
                    : [previous, value]
            } else {
                filters[key] = value
            }
        })

        return filters
    }

    applyFilters(form, filters) {
        Object.entries(filters).forEach(([name, value]) => {
            const controls = form.querySelectorAll(
                `[name="${this.escapeSelector(name)}"]`
            )

            controls.forEach(control => {
                if (control.type === "checkbox" || control.type === "radio") {
                    const values = Array.isArray(value) ? value : [value]
                    control.checked = values.includes(control.value)
                } else {
                    control.value = Array.isArray(value) ? value[0] || "" : value
                }

                control.dispatchEvent(new Event("change", { bubbles: true }))
            })
        })
    }

    readViews() {
        try {
            const value = localStorage.getItem(this.storageKeyValue)
            const views = value ? JSON.parse(value) : []

            return Array.isArray(views)
                ? views.filter(view =>
                    view &&
                    typeof view.id === "string" &&
                    typeof view.name === "string"
                )
                : []
        } catch {
            this.setStatus("Saved views cannot be read from browser storage.")
            return []
        }
    }

    writeViews(views) {
        try {
            localStorage.setItem(this.storageKeyValue, JSON.stringify(views))
            return true
        } catch {
            this.setStatus("Could not save the view. Check browser storage permissions.")
            return false
        }
    }

    createId() {
        if (window.crypto?.randomUUID) {
            return window.crypto.randomUUID()
        }

        return `${Date.now()}-${Math.random().toString(36).slice(2)}`
    }

    escapeSelector(value) {
        if (window.CSS?.escape) return CSS.escape(value)

        return value.replace(/["\\]/g, "\\$&")
    }

    setStatus(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = message
        }
    }
}