import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
        'addRegularStepOriginalButton',
        'addContainerStepOriginalButton',
        'wrapperStepAdditionButton',
        'closeOptionsModalButton'
        ];


    connect() {
        console.log("Algorithm step type select controller connected")

    }

    disconnect() {
        console.log("Algorithm step type select controller disconnected")
    }


    // PUBLIC
    handleRegularStepButtonClick(){
        this.addRegularStepOriginalButtonTarget.click()
        this.closeOptionsModal()
    }

    handleWrapperStepButtonClick(){
        // 1) close original modal
        this.closeOptionsModal()
        // 2) Open modal to select technology (algorithm or method)
        this.wrapperStepAdditionButtonTarget.click()

        // // 2) Create step
        // this.addWrapperStepOriginalButtonTarget.click()
        //
        // // 3) put data in step
        // this.closeOptionsModal()

    }

    handleContainerStepButtonClick(){
        this.addContainerStepOriginalButtonTarget.click()
        this.closeOptionsModal()
    }




    // PRIVATE
    closeOptionsModal(){
        this.closeOptionsModalButtonTarget.click()
    }


}