import { Controller } from '@hotwired/stimulus';
import { useMutation } from 'stimulus-use'

// controller use cases:
// remove substepAdditionCase - doesnt exists enymore
// const substepAdditionCase = "substep_addition";
// const wrapperStepAdditionCase = "wrapper_step_addition";
// TODO: REMOVE COMMENTS AFTER FIRST GOOD VERSION
// TOOD: REMOVE SELECTOR WHICH ARE NOT IN USE
// TODO: is there a possibility to refator it's to differnt files with includes?


// Doc: Each place on UI where we use selection of different objects specified as
// separate case, we pass this parameter during initialization of current controller
// Pattern: form_name + resource name + action
const algorithmFormWrapperStepAdditionCase = "algorithm_form_wrapper_step_addition";
const dpoInstructionSelectCase = "dpo_instruction_select";
const interfaceMemberAdditionCase = "interface_member_addition";
const containerMemberAdditionCase = "container_member_addition";
const folderItemAdditionCase = "folder_item_addition";
const interfaceGroupActionAdditionCase = "interface_group_form_action_addition";
const simpleClassAttributeAdditionCase = "simple_class_attribute_addition"
const simpleClassAttributeFormArticleAdditionCase = "simple_class_attribute_form_article_addition"
const algorithmFormClassLevelWrapperStepAdditionCase = "algorithm_form_class_level_wrapper_step_addition"



// Fields selectors
// const substepAdditionCaseNestedFields = '.substeps-nested-fields'
const wrapperStepAdditionCaseNestedFields = '.steps-nested-fields'
const interfaceMemberAdditionCaseNestedFields = '.nested-fields-interface-members'
const containerMemberAdditionCaseNestedFields = '.nested-fields-container-members'
const folderItemAdditionCaseNestedFields = '.nested-fields-folder-items'
const interfaceGroupActionAdditionCaseNestedFields = '.nested-fields-interface-group-actions'
const simpleClassAttributeAdditionCaseNestedFields = '.attributes-nested-fields'
const wrapperStepClassLevelAdditionCaseNestedFields = '.steps-nested-fields'

// 'select button' cases:
const aticleCase = "article";
const unitCase = "unit";
const algorithmCase = "algorithm";
const simpleClassCase = "simple_class";
const frameworkCase = "framework";
const MixedTechnologiesCase = "mixed_technologies";


export default class extends Controller {
    static targets = ['instructionModalInstance',
                      'searchInstructionsInstance',
                      'classTreeModal',
                     // Case 1. substeps addition
                     'addSubstepOriginalButton',
                     'substepFields', 'substepsArea',
                     // Case 1.2 Steps addition (algorithmFormWrapperStep Addition)
                      // TODO: rewrite stepsArea on NodesArea
                     'stepsArea', 'addWrapperStepOriginalButton',
                     'stepsNestedFields',
                     // Case 2. decision process object instruction select (DPO form)
                     'instructionableFieldsArea',
                     // Case 3. addition of interface member during creation of class
                     'interfaceMembersArea',
                     'addInterfaceMemberOriginalButton',
                     'interfaceMembersFields',
                     // Case 4. addition of container member during creation of class
                     'containerMembersArea',
                     'addContainerMemberOriginalButton',
                     // Case 5. addition of items to folders
                     'folderItemsArea',
                     'addFolderItemOriginalButton',
                      // Case 6. Interface Group form, Action addition
                      'interfaceMembersArea',
                      'addActionsToInterfaceGroupOriginalButton',
                      // Case 7. Simple class attribute addition
                      'simpleClassAttributesArea',
                      'addAttributeToSimpleClassOriginalButton',
                        // Case 8. simpleClassAttributeForm article addition
                      'simpleClassAttributeFormArea'
                     ];

    static values = {
        selectType: String
    }



    // TODO: fix miscalculation of postmutation variable
    //  if we remove + add mixing begavior, see how it's done in attachments '
    connect() {
        console.log("Remote select instruction controller connected")

        // General variables for all cases
        this.instructionId = ""
        this.instructionType = ""
        this.instructionPreviewContainer = null
        this.fieldsContainer = null

        // if (this.selectTypeValue == substepAdditionCase) {
        //     // mutation is used to check if new susbtep is added on ui side
        //     useMutation(this, {attributes: false, childList: true, characterData: false, subtree: true})
        //     this.afterclickSubstepsAmount = null
        //     this.currentSubstepsAmount = null
        //     this.postmutationSubstepsAmount = 0
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)) {
            // mutation is used to check if new susbtep is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterclickStepsAmount = null
            this.currentStepsAmount = null
            this.postmutationStepsAmount = 0
        } else if (this.selectTypeValue == dpoInstructionSelectCase) {
            // do nothing
        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            // mutation is used to check if new interface member is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickInterfaceMembersAmount = null
            this.currentInterfaceMembersAmount = null
            this.postmutationInterfaceMembersAmount = 0
        } else if (this.selectTypeValue == containerMemberAdditionCase) {
            // mutation is used to check if new class is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickContainerMembersAmount = null
            this.currentContainerMembersAmount = null
            this.postmutationContainerMembersAmount = 0
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            // mutation is used to check if new class is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickFolderItemsAmount = null
            this.currentFolderItemsAmount = null
            this.postmutationFolderItemsAmount = 0
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            // mutation is used to check if new class is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickInterfaceMembersAmount = null
            this.currentInterfaceMembersAmount = null
            this.postmutationInterfaceMembersAmount = 0
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase) {
            // mutation is used to check if new class is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickAttributesAmount = null
            this.currentAttributesAmount = null
            this.postmutationAttributesAAmount = 0
        } else if (this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            // do nothing
        }
    }


    disconnect() {
        console.log("Remote select instruction controller disconnected")
    }


    // Callbacks
    mutate(entries) {
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)) {
            console.log(`mutation for ${this.selectTypeValue} case triggered`)
            var nestedFields = wrapperStepAdditionCaseNestedFields
            this.afterclickStepsAmount = this.stepsAreaTarget.querySelectorAll(nestedFields).length
            // this.afterclickStepsAmount = this.stepsNestedFieldsTargets.length

            console.log("this.currentStepsAmount")
            console.log(this.currentStepsAmount)
            console.log("this.afterclickStepsAmount")
            console.log(this.afterclickStepsAmount)

            var changedAmount = (this.currentStepsAmount + 1)
            if ((changedAmount == this.afterclickStepsAmount) && (changedAmount != this.postmutationStepsAmount)) {
                console.log("New Wrapper step added!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationStepsAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }

        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            console.log(`mutation for ${interfaceMemberAdditionCase} case triggered`)

            var nestedFields = interfaceMemberAdditionCaseNestedFields
            this.afterClickInterfaceMembersAmount = this.interfaceMembersAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentInterfaceMembersAmount")
            console.log(this.currentInterfaceMembersAmount)
            console.log("this.afterClickInterfaceMembersAmount")
            console.log(this.afterClickInterfaceMembersAmount)

            var changedAmount = (this.currentInterfaceMembersAmount + 1)
            if ((changedAmount == this.afterClickInterfaceMembersAmount) && (changedAmount != this.postmutationInterfaceMembersAmount)) {
                console.log("New interface member added!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationInterfaceMembersAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        } else if (this.selectTypeValue == containerMemberAdditionCase) {
            console.log(`mutation for ${containerMemberAdditionCase} case triggered`)

            var nestedFields = containerMemberAdditionCaseNestedFields
            this.afterClickContainerMembersAmount = this.containerMembersAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentContainerMembersAmount")
            console.log(this.currentContainerMembersAmount)
            console.log("this.afterClickContainerMembersAmount")
            console.log(this.afterClickContainerMembersAmount)

            var changedAmount = (this.currentContainerMembersAmount + 1)
            if ((changedAmount == this.afterClickContainerMembersAmount) && (changedAmount != this.postmutationContainerMembersAmount)) {
                console.log("New container member added to container!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationContainerMembersAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            console.log(`mutation for ${folderItemAdditionCase} case triggered`)

            var nestedFields = folderItemAdditionCaseNestedFields
            this.afterClickFolderItemsAmount = this.folderItemsAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentFolderItemsAmount")
            console.log(this.currentFolderItemsAmount)
            console.log("this.afterClickFolderItemsAmount")
            console.log(this.afterClickFolderItemsAmount)

            var changedAmount = (this.currentFolderItemsAmount + 1)
            if ((changedAmount == this.afterClickFolderItemsAmount) && (changedAmount != this.postmutationFolderItemsAmount)) {
                console.log("New folder item added to folder!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationFolderItemsAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            console.log(`mutation for ${interfaceGroupActionAdditionCase} case triggered`)

            var nestedFields = interfaceGroupActionAdditionCaseNestedFields
            this.afterClickInterfaceMembersAmount = this.interfaceMembersAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentInterfaceMembersAmount")
            console.log(this.currentInterfaceMembersAmount)
            console.log("this.afterClickInterfaceMembersAmount")
            console.log(this.afterClickInterfaceMembersAmount)

            var changedAmount = (this.currentInterfaceMembersAmount + 1)
            if ((changedAmount == this.afterClickInterfaceMembersAmount) && (changedAmount != this.postmutationInterfaceMembersAmount)) {
                console.log("New Action added to Interface Group!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationInterfaceMembersAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase) {
            console.log(`mutation for ${simpleClassAttributeAdditionCase} case triggered`)

            var nestedFields = simpleClassAttributeAdditionCaseNestedFields
            this.afterClickAttributesAmount = this.simpleClassAttributesAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentAttributesAmount")
            console.log(this.currentAttributesAmount)
            console.log("this.afterClickAttributesAmount")
            console.log(this.afterClickAttributesAmount)

            var changedAmount = (this.currentAttributesAmount + 1)
            if ((changedAmount == this.afterClickAttributesAmount) && (changedAmount != this.postmutationAttributesAmount)) {
                console.log("New Attribute added to Simple Class!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationAttributesAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        }

    }


    // PUBLIC

    selectInstruction(event){
        // 1.save id of step to which we adding new substep
        this.instructionId = event.currentTarget.dataset.instructionid
        this.instructionType = event.currentTarget.dataset.instructiontype

        console.log("instructionId and instructionType")
        console.log(this.instructionId)
        console.log(this.instructionType)

        if (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase) {
            // 2.1 remove modal
            this.closeClassTreeModal()
        } else {
            // 2.1 clear inputs
            this.resetSearchForm()

            // 2.2 remove modal
            this.removeModal()
        }

        // Split on flows for each case

        // if (this.selectTypeValue == substepAdditionCase) {
        //     this.addSubstep()
        if (this.selectTypeValue == dpoInstructionSelectCase) {
            this.setInstruction()
        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            this.addInterfaceMember()
        } else if (this.selectTypeValue == containerMemberAdditionCase) {
            this.addContainerMember()
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            this.addFolderItem()
        } else if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
                    || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase) ) {
            this.addWrapperStep()
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            this.addActionToInterfaceGroup()
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase) {
            this.addAttributeToSimpleClass()
        } else if (this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            this.addArticleToSimpleClassAttribute()
        }
    }



    // PRIVATE

    setInstruction(){
        this.setInstructionValues()
        this.setInstructionPreviewContainer()
        this.loadPreview()
    }

    addFolderItem(){
        //Calculate amount of substep before adding new substep
        var nestedFields = folderItemAdditionCaseNestedFields
        this.currentFolderItemsAmount = this.folderItemsAreaTarget.querySelectorAll(nestedFields).length
        console.log("currentFolderItemsAmount:")
        console.log(this.currentFolderItemsAmount)

        // 3.click hidden button
        console.log("addFolderItemOriginalButtonTarget.click() fired")
        this.addFolderItemOriginalButtonTarget.click()
    }

    addContainerMember(){
        //Calculate amount of substep before adding new substep
        var nestedFields = containerMemberAdditionCaseNestedFields
        this.currentContainerMembersAmount = this.containerMembersAreaTarget.querySelectorAll(nestedFields).length
        console.log("currentContainerMembersAmount:")
        console.log(this.currentContainerMembersAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addContainerMemberOriginalButtonTarget.click() fired")
        this.addContainerMemberOriginalButtonTarget.click()
    }

    // addSubstep(){
    //     //Calculate amount of substep before adding new substep
    //     this.currentSubstepsAmount = this.substepsAreaTarget.querySelectorAll(substepAdditionCaseNestedFields).length
    //     console.log("currentSubstepsAmount")
    //     console.log(this.currentSubstepsAmount)
    //
    //     // 3.click hidden button under previous selected step
    //     // console.log(this.addSubstepOriginalButtonTarget)
    //     console.log("addSubstepOriginalButtonTarget.click() fired")
    //     this.addSubstepOriginalButtonTarget.click()
    // }

    addWrapperStep(){
        //Calculate amount of substep before adding new substep
        // this.currentStepsAmount = this.stepsAreaTarget.querySelectorAll(wrapperStepAdditionCaseNestedFields).length
        this.currentStepsAmount = this.stepsNestedFieldsTargets.length
        console.log("currentStepsAmount")
        console.log(this.currentStepsAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addWrapperStepOriginalButtonTarget.click() fired")
        this.addWrapperStepOriginalButtonTarget.click()
    }


    addInterfaceMember(){
        //Calculate amount of substep before adding new substep
        this.currentInterfaceMembersAmount = this.interfaceMembersAreaTarget.querySelectorAll(interfaceMemberAdditionCaseNestedFields).length
        console.log("currentInterfaceMembersAmount")
        console.log(this.currentInterfaceMembersAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addInterfaceMemberOriginalButtonTarget.click() fired")
        this.addInterfaceMemberOriginalButtonTarget.click()
    }

    addActionToInterfaceGroup(){
        //Calculate amount of substep before adding new substep
        this.currentInterfaceMembersAmount = this.interfaceMembersAreaTarget.querySelectorAll(interfaceGroupActionAdditionCaseNestedFields).length
        console.log("currentInterfaceMembersAmount")
        console.log(this.currentInterfaceMembersAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addActionsToInterfaceGroupOriginalButtonTarget.click() fired")
        this.addActionsToInterfaceGroupOriginalButtonTarget.click()
    }

    addAttributeToSimpleClass(){
        //Calculate amount of substep before adding new substep
        this.currentAttributesAmount = this.simpleClassAttributesAreaTarget.querySelectorAll(simpleClassAttributeAdditionCaseNestedFields).length
        console.log("currentAttributesAmount")
        console.log(this.currentAttributesAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addActionsToInterfaceGroupOriginalButtonTarget.click() fired")
        this.addAttributeToSimpleClassOriginalButtonTarget.click()
    }


    addArticleToSimpleClassAttribute(){
        this.setFieldsContainer()
        this.setInstructionValues()
        this.setInstructionPreviewContainer()
        this.loadPreview()
    }


    ////////////////////
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
    ////////////////////
    closeClassTreeModal(){
        const selectClassTreeModalController = this.application.getControllerForElementAndIdentifier(this.classTreeModalTarget, 'technology_pick_modal')
        selectClassTreeModalController.close()
    }


    setFieldsContainer(){
        // 4.1 select field container of added substep
        // if (this.selectTypeValue == substepAdditionCase) {
        //     var selector = substepAdditionCaseNestedFields
        //     this.fieldsContainer = [...this.substepsAreaTarget.querySelectorAll(selector)].pop()
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)) {
            // stepsNestedFieldsTargets ?
            var selector = wrapperStepAdditionCaseNestedFields
            this.fieldsContainer = [...this.stepsAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            var selector = interfaceMemberAdditionCaseNestedFields
            this.fieldsContainer = [...this.interfaceMembersAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == containerMemberAdditionCase) {
            var selector = containerMemberAdditionCaseNestedFields
            this.fieldsContainer = [...this.containerMembersAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            var selector = folderItemAdditionCaseNestedFields
            this.fieldsContainer = [...this.folderItemsAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            var selector = interfaceGroupActionAdditionCaseNestedFields
            this.fieldsContainer = [...this.interfaceMembersAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase) {
            var selector = simpleClassAttributeAdditionCaseNestedFields
            this.fieldsContainer = [...this.simpleClassAttributesAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            this.fieldsContainer = this.simpleClassAttributeFormAreaTarget
        }
        console.log("Last target or single target:")
        console.log(this.fieldsContainer)
    }

    // TODO: technology preview container instead of instructionPreviewContainer
    setInstructionPreviewContainer(){
        // if (this.selectTypeValue == substepAdditionCase) {
        //     this.instructionPreviewContainer = this.fieldsContainer.querySelector(".instruction-preview")
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)) {
            this.instructionPreviewContainer = this.fieldsContainer.querySelector(".instruction-preview")
        } else if (this.selectTypeValue == dpoInstructionSelectCase) {
            this.instructionPreviewContainer = this.instructionableFieldsAreaTarget.querySelector(".instruction-preview")
        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            this.instructionPreviewContainer = this.fieldsContainer.querySelector(".interface-member-preview")
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            this.instructionPreviewContainer = this.fieldsContainer.querySelector(".technology-preview")
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            this.instructionPreviewContainer = this.fieldsContainer.querySelector(".interface-member-preview")
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase
                   || this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            this.instructionPreviewContainer = this.fieldsContainer.querySelector(".attribute-preview")
        }
    }


    setInstructionValues(){
        // 4.2 stet variables for substep inputs field
        // if (this.selectTypeValue == substepAdditionCase) {
        //     this.setSubstepableInstructionValues()
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)) {
            this.setTechnologiableAlgorithmValues()
        } else if (this.selectTypeValue == dpoInstructionSelectCase) {
            this.setInstructionableInstructionValues()
        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            this.setInterfaceMemberValues()
        } else if (this.selectTypeValue == containerMemberAdditionCase) {
            this.setContainerMemberValues()
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            this.setFolderItemValues()
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            this.setInterfaceMemberValues()
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase
                   || this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            this.setAttributeValues()
        }
    }

    setAttributeValues(){
        // in this case we have only articles
        var idField = "article-id-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
    }

    setStepValues(){
        var idField = "technology-id-hidden-field"
        var typeField = "technology-type-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
        this.fieldsContainer.querySelector(`.${typeField}`).value = this.instructionType
    }

    setFolderItemValues(){
        var idField = "technology-id-hidden-field"
        var typeField = "technology-type-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
        this.fieldsContainer.querySelector(`.${typeField}`).value = this.instructionType
    }

    setContainerMemberValues(){
        var idField = "container-member-memberable-id-hidden-field"
        var typeField = "container-member-memberable-type-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
        this.fieldsContainer.querySelector(`.${typeField}`).value = "SimpleClasses::SimpleClass"
    }

    setInterfaceMemberValues(){
        var idField = "memberable-id-hidden-field"
        var typeField = "memberable-type-hidden-field"

        if (this.instructionType == unitCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Units::Unit"
        } else if (this.instructionType == algorithmCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Algorithms::Algorithm"
        }
    }

    setTechnologiableAlgorithmValues(){
        // define these 2 as targets
        var idField = "technologiable-id-hidden-field"
        var typeField = "technologiable-type-hidden-field"

        if (this.instructionType == unitCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Units::Unit"
        } else if (this.instructionType == algorithmCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Algorithms::Algorithm"
        }
    }


// setSubstepableInstructionValues(){
    //     var idField = "substepable-id-hidden-field"
    //     var typeField = "substepable-type-hidden-field"
    //
    //     if (this.instructionType == unitCase) {
    //         this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
    //         this.fieldsContainer.querySelector(`.${typeField}`).value = "Units::Unit"
    //     } else if (this.instructionType == algorithmCase) {
    //         this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
    //         this.fieldsContainer.querySelector(`.${typeField}`).value = "Algorithms::Algorithm"
    //     }
    // }



    setInstructionableInstructionValues(){
        var idField = "instructionable-id-hidden-field"
        var typeField = "instructionable-type-hidden-field"

        if (this.instructionType == unitCase) {
            this.instructionableFieldsAreaTarget.querySelector(`.${idField}`).value = this.instructionId
            this.instructionableFieldsAreaTarget.querySelector(`.${typeField}`).value = "Units::Unit"
        } else if (this.instructionType == algorithmCase) {
            this.instructionableFieldsAreaTarget.querySelector(`.${idField}`).value = this.instructionId
            this.instructionableFieldsAreaTarget.querySelector(`.${typeField}`).value = "Algorithms::Algorithm"
        }
    }


    // Load preview logic
    loadPreview(){
        var url = this.setLoadUrl()

        // 4.3 make request
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Preview loaded!")
                // console.log(data.preview)
                this.insertPreview(data)
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            }
        })
    }

    setLoadUrl(){
        // 4.2 stet variables for substep inputs field
        if (this.instructionType == unitCase) {
            var url = `/unit/units/${this.instructionId}/preview?type=${this.selectTypeValue}`
        } else if (this.instructionType == algorithmCase) {
            var url = `/algorithm/algorithms/${this.instructionId}/preview?case=${this.selectTypeValue}`
        } else if (this.instructionType == simpleClassCase) {
            var url = `/simple_class/simple_classes/${this.instructionId}/preview`
        } else if (this.instructionType == aticleCase) {
            var url = `/article/articles/${this.instructionId}/preview?preview_type=basic_preview`
        } else if (this.instructionType == frameworkCase) {
            var url = `/framework/frameworks/${this.instructionId}/preview`
        } else {
            console.log("Can not set load url, case not programmed")
        }
        return url;
    }

    insertPreview(data){
        if (this.selectTypeValue == algorithmFormWrapperStepAdditionCase
            || this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase
            || this.selectTypeValue == interfaceMemberAdditionCase
            || this.selectTypeValue == containerMemberAdditionCase
            || this.selectTypeValue == folderItemAdditionCase
            || this.selectTypeValue == simpleClassAttributeAdditionCase
            || this.selectTypeValue == interfaceGroupActionAdditionCase) {
            this.instructionPreviewContainer.insertAdjacentHTML('beforeend', data.preview)
        } else if (this.selectTypeValue == dpoInstructionSelectCase
                   || this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            this.instructionPreviewContainer.innerHTML = "";
            this.instructionPreviewContainer.insertAdjacentHTML('beforeend', data.preview)
        }
    }

}