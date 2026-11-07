
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        enabled: { type: Boolean, default: true }
    }

    connect() {
        this.boundKeydown = this.handleKeydown.bind(this)
        window.addEventListener("keydown", this.boundKeydown)
    }

    disconnect() {
        window.removeEventListener("keydown", this.boundKeydown)
    }

    handleKeydown(event) {
        if (!this.enabledValue || event.defaultPrevented) return
        if (this.isEditing(event.target)) return

        const modifier = event.metaKey || event.ctrlKey

        if (modifier && event.key.toLowerCase() === "k") {
            this.dispatchShortcut(event, "command-menu")
            return
        }

        if (modifier && event.key.toLowerCase() === "f") {
            const search = document.querySelector(
                '[data-admin-panel-comparison-intelligence-search-target="input"]'
            )

            if (search) {
                event.preventDefault()
                search.focus()
                search.select?.()
            }

            return
        }

        if (event.altKey && event.key === "ArrowRight") {
            this.dispatchShortcut(event, "next-section")
            return
        }

        if (event.altKey && event.key === "ArrowLeft") {
            this.dispatchShortcut(event, "previous-section")
        }
    }

    isEditing(element) {
        if (!(element instanceof HTMLElement)) return false

        return element.isContentEditable ||
            ["INPUT", "TEXTAREA", "SELECT"].includes(element.tagName)
    }

    dispatchShortcut(event, shortcut) {
        event.preventDefault()

        this.element.dispatchEvent(new CustomEvent(
            "comparison-intelligence:shortcut",
            {
                bubbles: true,
                detail: { shortcut }
            }
        ))
    }
}