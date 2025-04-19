// DOC: responsibility zone - perform js actions after show page for step loaded
import { Controller } from "@hotwired/stimulus"


export default class extends Controller {

    static targets = [
        'stepTitle',
    ];


    initialize() {
        console.log("step_show_controller initialized")
    }

    connect() {
        console.log("step_show_controller: connected")
    }

    disconnect() {
        console.log("step_show_controller: disconnected")
    }

    // PUBLIC

    focusOnTitle(){
        this.stepTitleTarget.scrollIntoView({
            behavior: 'smooth'
        });
    }

}