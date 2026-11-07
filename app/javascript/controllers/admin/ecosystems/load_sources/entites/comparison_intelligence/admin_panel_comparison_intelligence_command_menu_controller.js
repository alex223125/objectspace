
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu", "input", "item", "trigger", "emptyState"]

    connect() {
        this.isOpen = false
        this.previousFocus = null
        this.boundKeydown = this.handleDocumentKeydown.bind(this)
        document.addEventListener("keydown", this.boundKeydown)
        this.close(false)
    }

    disconnect() {
        document.removeEventListener("keydown", this.boundKeydown)
    }

    toggle(event) {
        event?.preventDefault()
        this.isOpen ? this.close() : this.open()
    }

    open(event) {
        event?.preventDefault()

        if (this.isOpen) return

        this.previousFocus = document.activeElement
        this.isOpen = true

        if (this.hasMenuTarget) {
            this.menuTarget.hidden = false
            this.menuTarget.setAttribute("aria-hidden", "false")
        }

        if (this.hasTriggerTarget) {
            this.triggerTarget.setAttribute("aria-expanded", "true")
        }

        if (this.hasInputTarget) {
            this.inputTarget.value = ""
            this.filter()
            this.inputTarget.focus()
        } else {
            this.firstVisibleItem()?.focus()
        }
    }

    close(restoreFocus = true) {
        this.isOpen = false

        if (this.hasMenuTarget) {
            this.menuTarget.hidden = true
            this.menuTarget.setAttribute("aria-hidden", "true")
        }

        if (this.hasTriggerTarget) {
            this.triggerTarget.setAttribute("aria-expanded", "false")
        }

        this.itemTargets.forEach(item => {
            item.hidden = false
        })

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = true
        }

        if (restoreFocus && this.previousFocus?.isConnected) {
            this.previousFocus.focus()
        }
    }

    filter() {
        const query = this.hasInputTarget
            ? this.inputTarget.value.trim().toLocaleLowerCase()
            : ""

        let visibleCount = 0

        this.itemTargets.forEach(item => {
            const searchable = [
                item.textContent,
                item.dataset.commandKeywords
            ].filter(Boolean).join(" ").toLocaleLowerCase()

            const visible = searchable.includes(query)
            item.hidden = !visible

            if (visible) visibleCount += 1
        })

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = visibleCount > 0
        }
    }

    handleDocumentKeydown(event) {
        const modifier = event.metaKey || event.ctrlKey

        if (modifier && event.key.toLowerCase() === "k") {
            event.preventDefault()
            this.toggle()
            return
        }

        if (!this.isOpen) return

        if (event.key === "Escape") {
            event.preventDefault()
            this.close()
            return
        }

        if (event.key === "ArrowDown" || event.key === "ArrowUp") {
            event.preventDefault()
            this.moveFocus(event.key === "ArrowDown" ? 1 : -1)
        }
    }

    moveFocus(direction) {
        const items = this.itemTargets.filter(item => !item.hidden)
        if (items.length === 0) return

        const index = items.indexOf(document.activeElement)
        const nextIndex = index < 0
            ? 0
            : (index + direction + items.length) % items.length

        items[nextIndex].focus()
    }

    firstVisibleItem() {
        return this.itemTargets.find(item => !item.hidden)
    }
}