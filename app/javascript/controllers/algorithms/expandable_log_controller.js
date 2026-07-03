import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "drawer", "icon" ]

    connect() {
        // Track open/close state within this component instance scope
        this.isOpen = false
    }

    toggle(event) {
        // Intercept bubbling to prevent nested layout containers from triggering multiple hits
        event.stopPropagation()

        this.isOpen = !this.isOpen

        if (this.isOpen) {
            this.reveal()
        } else {
            this.conceal()
        }
    }

    reveal() {
        // Dynamically compute exact layout space needed to ensure fluid down-slide animations
        this.drawerTarget.style.maxHeight = `${this.drawerTarget.scrollHeight}px`
        this.drawerTarget.classList.remove("opacity-0")
        this.drawerTarget.classList.add("opacity-100")

        // Rotate the prompt arrow inline graphic selector asset
        if (this.hasIconTarget) {
            this.iconTarget.classList.add("rotate-90", "text-cyan-500")
            this.iconTarget.classList.remove("text-cyan-500/40")
        }
    }

    conceal() {
        // Contract layout lines seamlessly back up to baseline height dimensions
        this.drawerTarget.style.maxHeight = "0"
        this.drawerTarget.classList.remove("opacity-100")
        this.drawerTarget.classList.add("opacity-0")

        if (this.hasIconTarget) {
            this.iconTarget.classList.remove("rotate-90", "text-cyan-500")
            this.iconTarget.classList.add("text-cyan-500/40")
        }
    }
}
