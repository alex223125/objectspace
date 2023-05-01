import { Controller } from '@hotwired/stimulus';
import { useMutation } from 'stimulus-use'

export default class extends Controller {
    static targets = ['addSubstepOriginalButton', 'instructionModalInstance',
                      'searchInstructionsInstance', 'substepFields', 'substepsArea'];

    connect() {
        console.log("Remote select instruction controller connected")


        this.instructionId = ""
        this.instructionType = ""
        this.fieldsContainer = null

        // mutation is used to check if new susbtep is added on ui side
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
        this.afterclickSubstepsAmount = null
        this.currentSubstepsAmount = null
        this.postmutationSubstepsAmount = 0
    }

    disconnect() {
        console.log("Remote select instruction controller disconnected")
    }


    mutate(entries) {

        console.log("this.currentSubstepsAmount")
        console.log(this.currentSubstepsAmount)

        console.log("this.afterclickSubstepsAmount")
        console.log(this.afterclickSubstepsAmount)
        this.afterclickSubstepsAmount = this.substepsAreaTarget.querySelectorAll('.nested-fields-substeps').length


        var changedAmount = (this.currentSubstepsAmount + 1)
        if ((changedAmount == this.afterclickSubstepsAmount) && (changedAmount != this.postmutationSubstepsAmount)) {
            console.log("New substep added!");
            this.setFieldsContainer()
            this.setInstructionValue()
            this.loadPreview()
            this.postmutationSubstepsAmount = changedAmount
        }
    }


    addSubstepRemoteButtonClick(event){

        // 1.save id of step to which we adding new substep
        this.instructionId = event.currentTarget.dataset.instructionid
        this.instructionType = event.currentTarget.dataset.instructiontype
        console.log("instructionId and instructionType")
        console.log(this.instructionId)
        console.log(this.instructionType)

        // 2.1 clear inputs
        this.resetSearchForm()

        // 2.2 remove modal
        this.removeModal()

        //Calculate amount of substep before adding new substep
        this.currentSubstepsAmount = this.substepsAreaTarget.querySelectorAll('.nested-fields-substeps').length
        console.log("currentSubstepsAmount")
        console.log(this.currentSubstepsAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addSubstepOriginalButtonTarget.click() fired")
        this.addSubstepOriginalButtonTarget.click()
    }


    // PRIVATE

    resetSearchForm(){
        // multiple instances on the same page
        this.searchInstructionsInstanceTargets.forEach(target => {
            var searchInstructionsController = this.application.getControllerForElementAndIdentifier(target, 'search_instructions')
            searchInstructionsController.resetForm()
        });
        // data-action="remote_select_instruction:addSubstepRemoteButtonClick->search_instructions#clearEntries"
    }

    removeModal(){
        const selectInstructionModalController = this.application.getControllerForElementAndIdentifier(this.instructionModalInstanceTarget, 'select_instruction_modal')
        selectInstructionModalController.close()
        // data-action="remote_select_instruction:addSubstepRemoteButtonClick->select_instruction_modal#close">
    }

    setFieldsContainer(){
        // 4.1 select field container of added substep
        this.fieldsContainer = [...this.substepsAreaTarget.querySelectorAll('.nested-fields-substeps')].pop()
        console.log("last target")
        console.log(this.fieldsContainer)
    }

    setInstructionValue(){
        // 4.2 stet variables for substep inputs field
        // if (this.instructionType == "unit_version") {
        //     this.fieldsContainer.querySelector(".unit-id-hidden-field").value = this.instructionId
        // } else if (this.instructionType == "algorithm_version") {
        //     this.fieldsContainer.querySelector(".algorithm-id-hidden-field").value = this.instructionId
        // }

        if (this.instructionType == "unit_version") {
            this.fieldsContainer.querySelector(".substepable-id-hidden-field").value = this.instructionId
            this.fieldsContainer.querySelector(".substepable-type-hidden-field").value = "Units::UnitVersion"
        } else if (this.instructionType == "algorithm_version") {
            this.fieldsContainer.querySelector(".substepable-id-hidden-field").value = this.instructionId
            this.fieldsContainer.querySelector(".substepable-type-hidden-field").value = "Algorithms::AlgorithmVersion"
        }

    }

    loadPreview(){
        // 4.2 stet variables for substep inputs field
        if (this.instructionType == "unit_version") {
            var url = `/unit/unit_versions/${this.instructionId}/preview`
        } else if (this.instructionType == "algorithm_version") {
            var url = `/algorithm/algorithm_versions/${this.instructionId}/preview`
        }

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Preview loaded!")
                // console.log(data.preview)
                this.fieldsContainer.querySelector(".instruction-preview").insertAdjacentHTML('beforeend', data.preview)
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                // this.page = this.page + 1
                // this.totalPages = data.pagination.pages
            }
        })
    }

}