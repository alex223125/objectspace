
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    confirm(event) {
        const message =
            this.element.dataset.confirmMessage ||
            "Are you sure you want to continue?"

        if (!window.confirm(message)) {
            event.preventDefault()
            event.stopPropagation()
        }
    }
}