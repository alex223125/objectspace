import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ['addSubstepOriginalButton', 'item', 'instructionModalInstance', 'searchInstructionsInstance'];


    connect() {
        console.log("Remote select instruction controller connected")
        console.log(this.addSubstepOriginalButtonTarget)

        // this.recalculateIndexes()
    }

    disconnect() {
        // this.recalculateIndexes()
        console.log("Remote select instruction controller disconnected")
    }






    addSubstepRemoteButtonClick(event){

        // 1.save id of step to which we adding new substep
        const instructionId = event.currentTarget.dataset.instructionid
        const instructionType = event.currentTarget.dataset.instructiontype
        console.log("####################")
        console.log(instructionId)
        console.log(instructionType)

        // 2.close popup and reset inputs and results in modal
        // this.dispatch("addSubstepRemoteButtonClick")


        // 2.1 clear inputs
        const searchInstructionsController = this.application.getControllerForElementAndIdentifier(this.searchInstructionsInstanceTarget, 'search_instructions')
        console.log(searchInstructionsController)
        searchInstructionsController.clearEntries()
        // data-action="remote_select_instruction:addSubstepRemoteButtonClick->search_instructions#clearEntries"

        // 2.2 remove modal
        const selectInstructionModalController = this.application.getControllerForElementAndIdentifier(this.instructionModalInstanceTarget, 'select_instruction_modal')
        console.log(selectInstructionModalController)
        selectInstructionModalController.close()
        // data-action="remote_select_instruction:addSubstepRemoteButtonClick->select_instruction_modal#close">




        // 3.click hidden button under previous selected step
        console.log(this.addSubstepOriginalButtonTarget)
        // this.addSubstepOriginalButtonTarget.click()


    }

    // closeModal() {
    //     this.dispatch("closeModal")
    //     console.log("close modal fired 1 ")
    // }

    setStepId(){

    }

    toggle({ target }) {
    }



}