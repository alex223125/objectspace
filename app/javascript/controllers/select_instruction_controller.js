import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ['item'];


    connect() {
        console.log("Select instruction controller connected")
        // this.recalculateIndexes()
    }

    disconnect() {
        // this.recalculateIndexes()
        console.log("Select instruction controller disconnected")
    }

    // 1.save id of step to which we addigng new substep
    // 2.when clicking click hidden button under previous selected step
    // 3.close popup

    setStepId(){

    }

    toggle({ target }) {
    }
}