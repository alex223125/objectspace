import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        message: {
            type: String,
            default: "Are you sure you want to continue?"
        }
    }

    confirm(event) {
        if (!window.confirm(this.messageValue)) {
            event.preventDefault()
        }
    }
}