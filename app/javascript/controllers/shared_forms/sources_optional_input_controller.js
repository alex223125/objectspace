import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['field',
                      'button']

    initialize() {
        console.log("sources_optional_input_controller initialized")
    }

    connect() {
        console.log("sources_optional_input_controller connected")
        // this.username = ''
    }

    disconnect() {
        console.log("sources_optional_input_controller disconnected")
    }

    // PUBLIC
    performService(){
        this.showInput()
        this.hideButton()
    }


    // PRIVATE
    showInput(){
        if (this.fieldTarget.classList.contains("hidden")) {
            this.fieldTarget.classList.remove("hidden")
        }
    }

    hideButton(){
        this.buttonTarget.classList.add("hidden")
    }
}