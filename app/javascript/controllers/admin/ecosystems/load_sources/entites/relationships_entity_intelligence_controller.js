import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["relationships"]

    connect() {
        this.element.dataset.intelligenceReady = "true"
    }

    toggleRelationships() {
        if (!this.hasRelationshipsTarget) return

        this.relationshipsTarget.classList.toggle("hidden")
    }
}