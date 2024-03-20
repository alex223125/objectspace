import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
    ]

    initialize() {
        console.log("link_attachments_nested_from_controller initialized")
    }

    connect() {
        console.log("link_attachments_nested_from_controller connected")
    }

    disconnect() {
        console.log("link_attachments_nested_from_controller disconnected")
    }

    // PUBLIC METHODS
    remove_association(event) {
        console.log("remove association triggered")
        event.preventDefault()

        let nestedForm = event.target.closest(".nested-fields")
        let removeButton = nestedForm.querySelector('.remove-nested-from-button')
        removeButton.click()
    }

}

