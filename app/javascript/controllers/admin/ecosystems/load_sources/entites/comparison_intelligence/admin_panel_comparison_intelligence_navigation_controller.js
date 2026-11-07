
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["link", "status"]

    connect() {
        this.updateActiveLink()
        this.boundPopState = () => this.updateActiveLink()
        window.addEventListener("popstate", this.boundPopState)
    }

    disconnect() {
        window.removeEventListener("popstate", this.boundPopState)
    }

    navigate(event) {
        const link = event.currentTarget
        const href = link.getAttribute("href")

        if (!href || href.startsWith("#") || link.target === "_blank") return
        if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return

        const destination = new URL(href, window.location.href)

        if (destination.origin !== window.location.origin) return

        this.linkTargets.forEach(item => {
            item.classList.remove("is-active")
            item.removeAttribute("aria-current")
        })

        link.classList.add("is-active")
        link.setAttribute("aria-current", "page")

        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                `Opening ${link.dataset.navigationLabel || link.textContent.trim()}`
        }
    }

    updateActiveLink() {
        const current = new URL(window.location.href)

        this.linkTargets.forEach(link => {
            const href = link.getAttribute("href")

            if (!href) return

            const destination = new URL(href, window.location.origin)
            const active =
                destination.pathname === current.pathname &&
                destination.search === current.search

            link.classList.toggle("is-active", active)

            if (active) {
                link.setAttribute("aria-current", "page")
            } else {
                link.removeAttribute("aria-current")
            }
        })
    }
}