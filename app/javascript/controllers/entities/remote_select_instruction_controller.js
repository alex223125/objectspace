// TODO: rename to remote_select_entity_controller and move to "entities" folder
// we use this controller not only for Articles - CheatSheetGroups, but also to select Frameworks and SimpleClasses
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
const algorithmFormClassLevelWrapperStepAdditionCase = "algorithm_form_class_level_wrapper_step_addition"
const algorithmFormFrameworkLevelWrapperStepAdditionCase = "algorithm_form_framework_level_wrapper_step_addition"
const simpleClassFormArticleToAttributeAttachmentCase = "simple_class_form_article_to_attribute_attachment"
// this case probably not in use, check it and remove if that's correct
const simpleClassAttributeFormArticleAdditionCase = "simple_class_attribute_form_article_addition"
const frameworkMembersFormFrameworkMembersAdditionCase = "framework_members_form_framework_members_addition"

// Fields selectors
// const substepAdditionCaseNestedFields = '.substeps-nested-fields'
const wrapperStepAdditionCaseNestedFields = '.steps-nested-fields'
const interfaceMemberAdditionCaseNestedFields = '.nested-fields-interface-members'
const containerMemberAdditionCaseNestedFields = '.nested-fields-container-members'
const folderItemAdditionCaseNestedFields = '.nested-fields-folder-items'
const interfaceGroupActionAdditionCaseNestedFields = '.nested-fields-interface-group-actions'
const simpleClassAttributeAdditionCaseNestedFields = '.attributes-nested-fields'
const wrapperStepClassLevelAdditionCaseNestedFields = '.steps-nested-fields'
const simpleClassFormArticleToAttributeAttachmentCaseNestedFields = '.article-attachment-nested-fields'
const frameworkMembersFormFrameworkMembersAdditionCaseNestedFields = '.framework-members-addition-nested-fields'

// 'select button' cases:
const articleCase = "article";
const unitCase = "unit";
const algorithmCase = "algorithm";
const cheatSheetCase = "cheat_sheet";
const cheatSheetGroupCase = "cheat_sheet_group";
const simpleClassCase = "simple_class";
const frameworkCase = "framework";
const MixedTechnologiesCase = "mixed_technologies";

//
const simpleClassClass = "SimpleClasses::SimpleClass"

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
                      'simpleClassAttributeFormArea',
                       // Case 9. addition of articles as attachments to attributes in simple class form
                       'simpleClassAttributeArticleAttahcmnetsArea',
                       'addArticleToAttributeInSimpleClassFormOriginalButton',
                       // Case 10. addition of framework members to framework folder
                       'frameworkMembersFormFrameworkMembersArea',
                       'addFrameworkMemberToFrameworkFolderInFrameworkMembersAdditionalFormOriginalButton'
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
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
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
            this.postmutationAttributesAmount = 0
        } else if (this.selectTypeValue == simpleClassFormArticleToAttributeAttachmentCase) {
            // mutation is used to check if new class is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickArticleAttachmentsAmount = null
            this.currentArticleAttachmentsAmount = null
            this.postmutationArticleAttachmentsAmount = 0
        } else if (this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            // do nothing
        } else if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            // mutation is used to check if new class is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
            this.afterClickArticleAttachmentsAmount = null
            this.currentArticleAttachmentsAmount = null
            this.postmutationArticleAttachmentsAmount = 0
        }
    }


    disconnect() {
        console.log("Remote select instruction controller disconnected")
    }


    // Callbacks start
    mutate(entries) {
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
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
        } else if (this.selectTypeValue == simpleClassFormArticleToAttributeAttachmentCase) {
            console.log(`mutation for ${simpleClassFormArticleToAttributeAttachmentCase} case triggered`)
            if (this.is_edit_form_field_display()) { return }

            var nestedFields = simpleClassFormArticleToAttributeAttachmentCaseNestedFields
            this.afterClickArticleAttachmentsAmount = this.simpleClassAttributeArticleAttahcmnetsAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentArticleAttachmentsAmount")
            console.log(this.currentArticleAttachmentsAmount)
            console.log("this.afterClickArticleAttachmentsAmount")
            console.log(this.afterClickArticleAttachmentsAmount)

            var changedAmount = (this.currentArticleAttachmentsAmount + 1)
            if ((changedAmount == this.afterClickArticleAttachmentsAmount) && (changedAmount != this.postmutationArticleAttachmentsAmount)) {
                console.log("New Article Attachment added to Attribute in Simple Class form!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationArticleAttachmentsAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        } else if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            console.log(`mutation for ${frameworkMembersFormFrameworkMembersAdditionCase} case triggered`)
            if (this.is_edit_form_field_display()) { return }

            var nestedFields = frameworkMembersFormFrameworkMembersAdditionCaseNestedFields
            this.afterClickFrameworkMembersAmount = this.frameworkMembersFormFrameworkMembersAreaTarget.querySelectorAll(nestedFields).length
            console.log("this.currentFrameworkMembersAmount")
            console.log(this.currentFrameworkMembersAmount)
            console.log("this.afterClickFrameworkMembersAmount")
            console.log(this.afterClickFrameworkMembersAmount)

            var changedAmount = (this.currentFrameworkMembersAmount + 1)
            if ((changedAmount == this.afterClickFrameworkMembersAmount) && (changedAmount != this.postmutationFrameworkMembersAmount)) {
                console.log("New Article Attachment added to Attribute in Simple Class form!");
                this.setFieldsContainer()
                this.setInstructionValues()
                this.setInstructionPreviewContainer()
                this.loadPreview()
                this.postmutationFrameworkMembersAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }
        }
    }
    // Callbacks end

    // PUBLIC

    selectInstruction(event){
        // 1.save id of step to which we adding new substep
        this.instructionId = event.currentTarget.dataset.instructionid
        this.instructionType = event.currentTarget.dataset.instructiontype

        console.log("instructionId and instructionType")
        console.log(this.instructionId)
        console.log(this.instructionType)

        // DOC: In case if we already added Decision Object in the form as Framework member
        // we dont need to add it second time, so we checking if it was added in the form, and if added
        // we ingonre selection of the same Decision Object
        if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            this.resetModalState()
            if (this.frameworkMemberWasAlreadyAddedInForm()) return
            this.checkThatFrameworkMemberExistsInTheFrameworkFolder(this.instructionId, this.instructionType)
        } else {
            this.resetModalState()
            this.dispatchSelectCase()
        }

    }



    // PRIVATE


    loadListOfExistingFrameworkMembersInFrameworkFolder(){
        var frameworkFolderUuid = $("#framework_folder")[0].value

        var url = `/framework_folder_members_list?framework_folder=${frameworkFolderUuid}`

        // 4.3 make request
        return $.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: function(response) {
                console.log("Framework members")
                console.log(response)
                var data = response;
            }
        })
    }


    checkThatFrameworkMemberExistsInTheFrameworkFolder(memberId, memberType){
        if (memberType == simpleClassCase ) {
            var backendClass = simpleClassClass
        }
        // var ListOfExistingInFrameworkFolderMembers = this.loadListOfExistingFrameworkMembersInFrameworkFolder()

        var that = this
        this.loadListOfExistingFrameworkMembersInFrameworkFolder().done(function(response) {
            var match = that.getMatch(response, memberId, backendClass)
            if (match) {
                console.log("Framework member already exists in the Framework Folder")
            } else {
                console.log("Framework member doesnt exists in the Framework Folder")
                // DOC: Means that we adding framework member into form
                that.resetModalState()
                that.dispatchSelectCase()
            }
        });

        // .then(function (response) {
        //     var matches = this.getMatches(response, memberId, backendClass)
        //     if (matches.length > 0) {
        //         console.log("Framework member already exists in the Framework Folder")
        //         return true
        //     } else {
        //         console.log("Framework member doesnt exists in the Framework Folder")
        //         return false
        //     }
        // }).catch(function (errorMessage) {
        //         // this function is called whenever an error occurs
        //         // errorMessage contains the error message
        // });
    }

    getMatch(data, memberId, backendClass){
        return data.find(obj => obj.id == memberId && obj.class == backendClass )
    }

    frameworkMemberWasAlreadyAddedInForm(){
        if (this.numberOfFrameworkMembersMatches() > 0) {
            console.log("remote_select_instruction_controller: Selected Framework member already added in the form")
            // TODO: flash popup - framework member was already added in the form
            return true
        } else {
            return false
        }
    }

    numberOfFrameworkMembersMatches(){
        let addFrameworkMembers = this.frameworkMembersFormFrameworkMembersAreaTarget.querySelectorAll(frameworkMembersFormFrameworkMembersAdditionCaseNestedFields)
        console.log("remote_select_instruction_controller: All Framework Members")
        console.log(addFrameworkMembers)

        let allFrameworkMembersArray = [...addFrameworkMembers]
        var that = this
        let matches = allFrameworkMembersArray.filter(function (frameworkMember) {
            let idFieldSelector = "framework-memberable-id-hidden-field"
            let typeFieldSelector = "framework-memberable-type-hidden-field"

            let fieldFrameworkMemberId = frameworkMember.querySelector(`.${idFieldSelector}`).value
            let fieldFrameworkMemberType = frameworkMember.querySelector(`.${typeFieldSelector}`).value
            //
            // if (that.sectionType == cheatSheetCase) {
            //     that.correlatedSectionType = cheatSheetClass
            // } else if (that.sectionType == cheatSheetGroupCase) {
            //     that.correlatedSectionType = cheatSheetGroupClass
            // }

            // else if (that.linkAttachmentType == unitCase) {
            //     let correlatedLinkAttachmentType = unitClass
            // } else if (that.linkAttachmentType == algorithmCase) {
            //     let correlatedLinkAttachmentType = algorithmClass
            // }

            if (that.instructionType == simpleClassCase) {
                that.correlatedFrameworkMembmerType = simpleClassClass
            }
            console.log("fieldFrameworkMemberId")
            console.log(fieldFrameworkMemberId)

            console.log("that.instructionId")
            console.log(that.instructionId)

            console.log("fieldFrameworkMemberType")
            console.log(fieldFrameworkMemberType)

            console.log("that.instructionType")
            console.log(that.instructionType)

            return (fieldFrameworkMemberId == that.instructionId) && (fieldFrameworkMemberType == that.correlatedFrameworkMembmerType)
        });
        let amount = matches.length
        return amount
    }

    // doc: sometimes we have edit form where we show preview of attachment
    // with hidden field. If mutation runs it sets it value to blank string as
    // in connect() method. To prevent this we checking if we dealing with edit from
    // where attachemnt already added.
    is_edit_form_field_display(){
        if (this.instructionId == "" && this.instructionType == "") {
            return true
        } else {
            return false
        }
    }

    dispatchSelectCase(){
        // Split on flows for each case

        console.log("Current select type:")
        console.log(this.selectTypeValue)
        // if (this.selectTypeValue == substepAdditionCase) {
        //     this.addSubstep()
        if (this.selectTypeValue == dpoInstructionSelectCase) {
            console.log("dpoInstructionSelectCase triggered")
            this.setInstruction()
        } else if (this.selectTypeValue == interfaceMemberAdditionCase) {
            console.log("interfaceMemberAdditionCase triggered")
            this.addInterfaceMember()
        } else if (this.selectTypeValue == containerMemberAdditionCase) {
            console.log("containerMemberAdditionCase triggered")
            this.addContainerMember()
        } else if (this.selectTypeValue == folderItemAdditionCase) {
            console.log("folderItemAdditionCase triggered")
            this.addFolderItem()
        } else if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
            console.log("algorithmFormWrapperStepAdditionCase or algorithmFormClassLevelWrapperStepAdditionCase or algorithmFormFrameworkLevelWrapperStepAdditionCase triggered")
            this.addWrapperStep()
        } else if (this.selectTypeValue == interfaceGroupActionAdditionCase) {
            console.log("interfaceGroupActionAdditionCase triggered")
            this.addActionToInterfaceGroup()
        } else if (this.selectTypeValue == simpleClassAttributeAdditionCase) {
            console.log("simpleClassAttributeAdditionCase triggered")
            this.addAttributeToSimpleClass()
        } else if (this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            console.log("simpleClassAttributeFormArticleAdditionCase triggered")
            this.addArticleToSimpleClassAttribute()
        } else if (this.selectTypeValue == simpleClassFormArticleToAttributeAttachmentCase) {
            console.log("simpleClassFormArticleToAttributeAttachmentCase triggered")
            this.addArticleAttachmentToSimpleClassAttribute()
        } else if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            console.log("frameworkMembersFormFrameworkMembersAdditionCase triggered")
            this.addFrameworkMemberToFrameworkFolder()
        }


    }

    resetModalState(){
        if ((this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
            // 2.1 remove modal
            this.closeClassTreeModal()
        } else {
            // 2.1 clear inputs
            this.resetSearchForm()

            // 2.2 remove modal
            this.removeModal()
        }
    }

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
        this.currentAttributesAmount = this.simpleClassAttributesAreaTarget
            .querySelectorAll(simpleClassAttributeAdditionCaseNestedFields).length
        console.log("currentAttributesAmount")
        console.log(this.currentAttributesAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addActionsToInterfaceGroupOriginalButtonTarget.click() fired")
        this.addAttributeToSimpleClassOriginalButtonTarget.click()
    }

    addArticleAttachmentToSimpleClassAttribute(){
        //Calculate amount of attachments before adding new substep
        this.currentArticleAttachmentsAmount = this.simpleClassAttributeArticleAttahcmnetsAreaTarget
            .querySelectorAll(simpleClassFormArticleToAttributeAttachmentCaseNestedFields).length
        console.log("currentArticleAttachmentsAmount")
        console.log(this.currentArticleAttachmentsAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addArticleToAttributeInSimpleClassFormOriginalButtonTarget.click() fired")
        this.addArticleToAttributeInSimpleClassFormOriginalButtonTarget.click()
    }

    addFrameworkMemberToFrameworkFolder(){
        //Calculate amount of attachments before adding new substep
        this.currentFrameworkMembersAmount = this.frameworkMembersFormFrameworkMembersAreaTarget
            .querySelectorAll(frameworkMembersFormFrameworkMembersAdditionCaseNestedFields).length
        console.log("currentFrameworkMembersAmount")
        console.log(this.currentFrameworkMembersAmount)

        // 3.click hidden button under previous selected step
        // console.log(this.addSubstepOriginalButtonTarget)
        console.log("addFrameworkMemberToFrameworkFolderInFrameworkMembersAdditionalFormOriginalButtonTarget.click() fired")
        this.addFrameworkMemberToFrameworkFolderInFrameworkMembersAdditionalFormOriginalButtonTarget.click()
    }

    addArticleToSimpleClassAttribute(){
        this.setFieldsContainer()
        this.setInstructionValues()
        this.setInstructionPreviewContainer()
        this.loadPreview()
    }


    ////////////////////
    // Remove modal logic
    resetSearchForm(){
        // multiple instances on the same page
        this.searchInstructionsInstanceTargets.forEach(target => {
            var searchInstructionsController = this.application.getControllerForElementAndIdentifier(target, 'search_instructions')
            searchInstructionsController.resetForm()
        });
        // data-action="remote_select_instruction:addSubstepRemoteButtonClick->search_instructions#clearEntries"
    }

    removeModal(){
        let openedModal = this.instructionModalInstanceTargets.filter((element) => {
            // Looking for one which is we see on ui at the current moment (there a lot of others for each step)
            // if (!element.querySelector(".modal-container").classList.contains("hidden")) {
            if (!element.classList.contains("hidden")) {
                return true
            } else {
                return false
            }
        });
        console.log("remote_select_instruction_controller: active modal found")
        console.log(openedModal[0])

        // DOC: For one selection on each case.
        // In one case we dealing with select_instruction_modal
        // In second case we dealing with technology_pick_modal
        // WRONG! Currently it already handlend in the method above
        const selectInstructionModalController = this.application.getControllerForElementAndIdentifier(openedModal[0], 'select_instruction_modal')
        selectInstructionModalController.close()

        // if (selectInstructionModalController) {
        //     selectInstructionModalController.close()
        // } else {
        //     this.closeClassTreeModal()
        // }

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
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
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
        } else if (this.selectTypeValue == simpleClassFormArticleToAttributeAttachmentCase) {
            var selector = simpleClassFormArticleToAttributeAttachmentCaseNestedFields
            this.fieldsContainer = [...this.simpleClassAttributeArticleAttahcmnetsAreaTarget.querySelectorAll(selector)].pop()
        } else if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            var selector = frameworkMembersFormFrameworkMembersAdditionCaseNestedFields
            console.log("this.frameworkMembersFormFrameworkMembersAreaTarget")
            console.log(this.frameworkMembersFormFrameworkMembersAreaTarget)

            this.fieldsContainer = [...this.frameworkMembersFormFrameworkMembersAreaTarget.querySelectorAll(selector)].pop()
        }
        console.log("Last target or single target:")
        console.log(this.fieldsContainer)
    }

    // TODO: technology preview container instead of instructionPreviewContainer
    // technolgy == all, including articles and dec proc objects
    setInstructionPreviewContainer(){
        // if (this.selectTypeValue == substepAdditionCase) {
        //     this.instructionPreviewContainer = this.fieldsContainer.querySelector(".instruction-preview")
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
            || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
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
        } else if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            this.instructionPreviewContainer = this.fieldsContainer.querySelector(".framework-member-preview")
        }
    }


    setInstructionValues(){
        // 4.2 stet variables for substep inputs field
        // if (this.selectTypeValue == substepAdditionCase) {
        //     this.setSubstepableInstructionValues()
        if ((this.selectTypeValue == algorithmFormWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormClassLevelWrapperStepAdditionCase)
             || (this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase)) {
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
        } else if (this.selectTypeValue == simpleClassFormArticleToAttributeAttachmentCase) {
            this.setArticleAttachmentValue()
        } else if (this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            this.setFrameworkMemberValue()
        }
    }

    //// set values methods
    setArticleAttachmentValue(){
        // in this case we have only article
        var idField = "article-id-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
    }


    setAttributeValues(){
        // in this case we have only article
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

    // TODO: only units and algorithms, or also articles, cheatsheets and ect?
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


    setFrameworkMemberValue(){
        var idField = "framework-memberable-id-hidden-field"
        var typeField = "framework-memberable-type-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
        this.fieldsContainer.querySelector(`.${typeField}`).value = "SimpleClasses::SimpleClass"
    }


    setTechnologiableAlgorithmValues(){
        // define these 2 as targets
        var idField = "technologiable-id-hidden-field"
        var typeField = "technologiable-type-hidden-field"

        if (this.instructionType == articleCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Articles::Article"
        } else if (this.instructionType == unitCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Units::Unit"
        } else if (this.instructionType == algorithmCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "Algorithms::Algorithm"
        } else if (this.instructionType == cheatSheetCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "CheatSheets::CheatSheet"
        } else if (this.instructionType == cheatSheetGroupCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.instructionId
            this.fieldsContainer.querySelector(`.${typeField}`).value = "CheatSheetGroups::CheatSheetGroup"
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
    ////

    // TODO: add asych rendering of preview with message something went wrong and reload button
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
        if (this.instructionType == articleCase) {
            var url = `/article/articles/${this.instructionId}/preview?preview_type=basic_preview`
        } else if (this.instructionType == unitCase) {
            var url = `/unit/units/${this.instructionId}/preview?type=${this.selectTypeValue}`
        } else if (this.instructionType == algorithmCase) {
            var url = `/algorithm/algorithms/${this.instructionId}/preview?preview_type=${this.selectTypeValue}`
        } else if (this.instructionType == cheatSheetCase) {
            var url = `/cheat_sheet/cheat_sheets/${this.instructionId}/preview?preview_type=${this.selectTypeValue}`
        } else if (this.instructionType == cheatSheetGroupCase) {
            var url = `/cheat_sheet_group/cheat_sheet_groups/${this.instructionId}/preview?preview_type=${this.selectTypeValue}`
        } else if (this.instructionType == simpleClassCase) {
            var url = `/simple_class/simple_classes/${this.instructionId}/preview`
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
            || this.selectTypeValue == algorithmFormFrameworkLevelWrapperStepAdditionCase
            || this.selectTypeValue == interfaceMemberAdditionCase
            || this.selectTypeValue == containerMemberAdditionCase
            || this.selectTypeValue == folderItemAdditionCase
            || this.selectTypeValue == simpleClassAttributeAdditionCase
            || this.selectTypeValue == interfaceGroupActionAdditionCase
            || this.selectTypeValue == simpleClassFormArticleToAttributeAttachmentCase
            || this.selectTypeValue == frameworkMembersFormFrameworkMembersAdditionCase) {
            this.instructionPreviewContainer.insertAdjacentHTML('beforeend', data.preview)
        } else if (this.selectTypeValue == dpoInstructionSelectCase
                   || this.selectTypeValue == simpleClassAttributeFormArticleAdditionCase) {
            this.instructionPreviewContainer.innerHTML = "";
            this.instructionPreviewContainer.insertAdjacentHTML('beforeend', data.preview)
        }
    }

}
