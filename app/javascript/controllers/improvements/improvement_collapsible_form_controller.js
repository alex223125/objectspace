import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "panel", "triggerContainer" ]

    connect() {
        console.log("Improvement Collapsible Form Controller initialized")
        // Verified setup pipeline ready
    }

    // Smoothly slide open the submission form matrix
    reveal(event) {
        event.preventDefault()

        // 1. Unhide block instantly so geometry styles process accurately
        this.panelTarget.classList.remove("hidden")

        // 2. Micro-timeout lets the DOM register class state resets before running transformations
        setTimeout(() => {
            this.panelTarget.classList.remove("max-h-0", "opacity-0", "scale-95")
            this.panelTarget.classList.add("max-h-[1500px]", "opacity-100", "scale-100")

            // Hide the big button wrapper to clear document vertical space
            this.triggerContainerTarget.classList.add("scale-90", "opacity-0", "pointer-events-none")

            // Smoothly scroll the new container into view after animation finish
            setTimeout(() => {
                this.triggerContainerTarget.classList.add("hidden")
                this.panelTarget.scrollIntoView({ behavior: "smooth", block: "start" })
            }, 500)
        }, 10)
    }

    // Gracefully transition back to compact view state
    conceal(event) {
        event.preventDefault()

        // Bring trigger container back to life
        this.triggerContainerTarget.classList.remove("hidden")

        setTimeout(() => {
            this.triggerContainerTarget.classList.remove("scale-90", "opacity-0", "pointer-events-none")

            // Retract panel properties back down to base definitions
            this.panelTarget.classList.remove("max-h-[1500px]", "opacity-100", "scale-100")
            this.panelTarget.classList.add("max-h-0", "opacity-0", "scale-95")

            // Add structural hidden attributes once the transition ends
            setTimeout(() => {
                this.panelTarget.classList.add("hidden")
            }, 500)
        }, 10)
    }
}
