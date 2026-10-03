import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "details",
        "copyButton",
        "toast"
    ]

    connect() {
        this.toastTimer = null

        this.handleKeydown =
            this.handleKeydown.bind(this)

        document.addEventListener(
            "keydown",
            this.handleKeydown
        )
    }

    disconnect() {
        document.removeEventListener(
            "keydown",
            this.handleKeydown
        )

        if (this.toastTimer) {
            clearTimeout(this.toastTimer)
        }
    }

    toggle(event) {
        const button =
            event.currentTarget

        const targetId =
            button.dataset.target

        if (!targetId) {
            return
        }

        const target =
            this.element.querySelector(
                `[data-comparison-details="${targetId}"]`
            )

        if (!target) {
            return
        }

        const expanded =
            target.hidden === false

        target.hidden = expanded

        button.setAttribute(
            "aria-expanded",
            String(!expanded)
        )

        const label =
            button.querySelector(
                "[data-toggle-label]"
            )

        if (label) {
            label.textContent =
                expanded
                    ? "View details"
                    : "Hide details"
        }
    }

    copy(event) {
        const button =
            event.currentTarget

        const value =
            button.dataset.value || ""

        if (!value) {
            return
        }

        if (
            !navigator.clipboard ||
            !navigator.clipboard.writeText
        ) {
            return
        }

        navigator.clipboard
            .writeText(value)
            .then(() => {
                this.showCopied(button)
            })
            .catch(() => {
                this.showToast(
                    "Unable to copy value."
                )
            })
    }

    showCopied(button) {
        const original =
            button.dataset.originalLabel ||
            button.textContent

        button.dataset.originalLabel =
            original

        button.textContent =
            "✓ Copied"

        button.classList.add(
            "text-emerald-600"
        )

        setTimeout(() => {
            button.textContent =
                original

            button.classList.remove(
                "text-emerald-600"
            )
        }, 1200)

        this.showToast(
            "Copied to clipboard."
        )
    }

    showToast(message) {
        if (!this.hasToastTarget) {
            return
        }

        this.toastTarget.textContent =
            message

        this.toastTarget.hidden =
            false

        if (this.toastTimer) {
            clearTimeout(this.toastTimer)
        }

        this.toastTimer =
            setTimeout(() => {
                this.toastTarget.hidden =
                    true
            }, 1800)
    }

    handleKeydown(event) {
        if (
            event.key === "/" &&
            !this.isTyping(event.target)
        ) {
            event.preventDefault()

            const search =
                this.element.querySelector(
                    "[data-comparison-search]"
                )

            search?.focus()

            return
        }

        if (
            event.key === "Escape"
        ) {
            const search =
                this.element.querySelector(
                    "[data-comparison-search]"
                )

            if (
                search &&
                document.activeElement === search
            ) {
                search.value = ""

                search.dispatchEvent(
                    new Event("input", {
                        bubbles: true
                    })
                )

                search.blur()
            }
        }
    }

    isTyping(element) {
        if (!element) {
            return false
        }

        const tag =
            element.tagName?.toLowerCase()

        return (
            tag === "input" ||
            tag === "textarea" ||
            tag === "select" ||
            element.isContentEditable
        )
    }
}