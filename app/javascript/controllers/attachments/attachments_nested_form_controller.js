import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
        // "articleAttachmentFieldsTemplate",
        // "addedAttachmentsArea",
        // "removeArticleAttachmentOriginalButton"
    ]

    initialize() {
        console.log("attachments_nested_form controller initialized")
    }

    connect() {
        console.log("attachments_nested_form controller connected")
    }

    disconnect() {
        console.log("attachments_nested_form controller disconnected")
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

