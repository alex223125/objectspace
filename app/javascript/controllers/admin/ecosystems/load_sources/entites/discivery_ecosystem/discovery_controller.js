import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.classList.add("discovery-engine-ready")
    }

    focusRecommendation(event) {
        const target = event.currentTarget.dataset.target

        if (!target) return

        const element = document.getElementById(target)

        if (!element) return

        element.scrollIntoView({
            behavior: "smooth",
            block: "center"
        })

        element.classList.add("ring-4", "ring-orange-300")

        window.setTimeout(() => {
            element.classList.remove("ring-4", "ring-orange-300")
        }, 1200)
    }
}