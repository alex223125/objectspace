// TODO: rename to algorithm_node_type_select
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [

        // steps
        'closeOptionsModalButton',
        'addRegularStepOriginalButton',
        'addContainerStepOriginalButton',
        'wrapperStepAdditionButton',

        // control structures
        'closeControlStructuresOptionsModalButton',
        'addSingleAlternativeControlStructureOriginalButton'
        ];


    connect() {
        console.log("Algorithm step type select controller connected")
    }

    disconnect() {
        console.log("Algorithm step type select controller disconnected")
    }


    // PUBLIC

    // 1.1 steps options:
    handleRegularStepButtonClick(){
        this.addRegularStepOriginalButtonTarget.click()
        this.closeOptionsModal()
    }

    handleWrapperStepButtonClick(){
        // 1) close original modal
        this.closeOptionsModal()
        // 2) Open modal to select technology (algorithm or method)
        this.wrapperStepAdditionButtonTarget.click()
    }

    handleContainerStepButtonClick(){
        this.addContainerStepOriginalButtonTarget.click()
        this.closeOptionsModal()
    }


    /// 1.2 control structures options:
    handleSingleAlternativeControlStructureButtonClick(){
        this.addSingleAlternativeControlStructureOriginalButtonTarget.click()
        this.closeControlStructuresOptionsModal()
    }




    // PRIVATE
    closeOptionsModal(){
        this.closeOptionsModalButtonTarget.click()
    }

    closeControlStructuresOptionsModal(){
        this.closeControlStructuresOptionsModalButtonTarget.click()
    }


}