import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
        'removeSectionOriginalButton',
    ]

    initialize() {
        console.log("cheat_sheet_group_sections_nested_form_controller initialized")
    }

    connect() {
        console.log("cheat_sheet_group_sections_nested_form_controller connected")
    }

    disconnect() {
        console.log("cheat_sheet_group_sections_nested_form_controller disconnected")
    }

    // PUBLIC METHODS
    remove_association(event) {
        console.log("cheat_sheet_group_sections_nested_form_controller: remove association triggered")
        event.preventDefault()
        //
        // let nestedForm = event.target.closest(".nested-fields")
        // // let removeButton = nestedForm.querySelector('.remove-nested-from-button')
        // let removeButton = nestedForm.find(this.removeSectionOriginalButtonTarget)
        this.removeSectionOriginalButtonTarget.click()
    }

}

