import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "annotations",
        "evidence"
    ]

    connect() {
        this.showAnnotations()
    }

    showAnnotations(event) {
        if (event) {
            event.preventDefault()
        }

        if (this.hasAnnotationsTarget) {
            this.annotationsTarget.classList.remove("hidden")
        }

        if (this.hasEvidenceTarget) {
            this.evidenceTarget.classList.add("hidden")
        }
    }

    showEvidence(event) {
        if (event) {
            event.preventDefault()
        }

        if (this.hasEvidenceTarget) {
            this.evidenceTarget.classList.remove("hidden")
        }

        if (this.hasAnnotationsTarget) {
            this.annotationsTarget.classList.add("hidden")
        }
    }
}