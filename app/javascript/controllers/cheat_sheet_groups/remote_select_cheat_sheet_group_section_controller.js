// doc: responsibility zone: select technology as Section of Cheat sheet group
import { Controller } from '@hotwired/stimulus'
import { useMutation } from 'stimulus-use'

const sectionCaseNestedFields = '.nested-fields-section'

const articleCase = "article"
const articleClass = "Articles::Article"

const unitCase = "unit"
const unitClass = "Units::Unit"

const cheatSheetCase = "cheat_sheet"
const cheatSheetClass = "CheatSheets::CheatSheet"

const cheatSheetGroupCase = "cheat_sheet_group"
const cheatSheetGroupClass = "CheatSheetGroups::CheatSheetGroup"


export default class extends Controller {
    static targets = [
        'searchInstructionsInstance',
        'instructionModalInstance',

        'sectionsArea',
        'addSectionOriginalButton',
    ]

    initialize(){
    }

    connect() {
        console.log("remote_select_cheat_sheet_group_section_controller connected")

        // General variables for all cases
        this.sectionId = ""
        this.sectionType = ""

        this.addMutationListener()
        this.loadExistingAttachments()
    }

    disconnect() {
        console.log("remote_select_cheat_sheet_group_section_controller disconnected")
    }


    // Callbacks
    mutate(entries) {
        console.log(`remote_select_cheat_sheet_group_section_controller: mutation triggered`)

        if (this.is_edit_form_field_display()) {
            console.log("remote_select_cheat_sheet_group_section_controller: Edit form field display mutation")
            return
        }

        var nestedFields = sectionCaseNestedFields
        this.afterClickSectionsAmount = this.sectionsAreaTarget.querySelectorAll(nestedFields).length

        console.log("remote_select_cheat_sheet_group_section_controller: this.currentSectionsAmount")
        console.log(this.currentSectionsAmount)
        console.log("remote_select_cheat_sheet_group_section_controller: this.afterClickSectionsAmount")
        console.log(this.afterClickSectionsAmount)

        // Doc: Case 2: Should go in code before case 1. This is the case when we removed
        // some of the sections and have disbalanse in this.postmutationSectionsAmount variable
        // so we calibrating it back to normal situation
        if (this.afterClickSectionsAmount < this.postmutationSectionsAmount){
            this.postmutationSectionsAmount = this.afterClickSectionsAmount
        }

        // Doc: Case 1. When we increase amount of sections
        var changedAmount = (this.currentSectionsAmount + 1)
        if ((changedAmount == this.afterClickSectionsAmount) && (changedAmount != this.postmutationSectionsAmount)) {
            console.log("remote_select_cheat_sheet_group_section_controller: New Section added!");
            this.setFieldsContainer()
            this.setSectionValues()
            this.setPreviewContainer()
            this.setLoadUrl()
            this.loadPreview()
            this.postmutationSectionsAmount = changedAmount
        } else {
            console.log("remote_select_cheat_sheet_group_section_controller: Amount not changed or error");
        }
    }

    // PUBLIC
    selectSection(event){
        this.sectionId = event.currentTarget.dataset.sectionid
        this.sectionType = event.currentTarget.dataset.sectiontype

        console.log("remote_select_cheat_sheet_group_section_controller: sectionId and sectionType")
        console.log(this.sectionId)
        console.log(this.sectionType)

        this.resetSearchForm()
        this.removeModal()

        if (this.was_already_added_sections()) return

        // DOC: in future buttons can be different
        if (this.sectionType == articleCase) {
            this.addCheatSheetSection()
        } else if (this.sectionType == unitCase) {
            this.addCheatSheetSection()
        } else if (this.sectionType == cheatSheetCase) {
            this.addCheatSheetSection()
        } else if (this.sectionType == cheatSheetGroupCase) {
            this.addCheatSheetSection()
        }
    }

    // PRIVATE

    addCheatSheetSection() {
        //Calculate amount of substep before adding new substep
        var nestedFields = sectionCaseNestedFields
        this.currentSectionsAmount = this.sectionsAreaTarget.querySelectorAll(nestedFields).length
        console.log("remote_select_cheat_sheet_group_section_controller: current sections:")
        console.log(this.currentSectionsAmount)

        // 3.click hidden button under previous selected step
        console.log("remote_select_cheat_sheet_group_section_controller: addSectionOriginalButtonTarget.click() fired")
        this.addSectionOriginalButtonTarget.click()
    }

    addMutationListener() {
        console.log("remote_select_cheat_sheet_group_section_controller: mutation listener added")
        // mutation is used to check if new attachment is added on ui side
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree: true})
        this.afterClickSectionsAmount = null
        this.currentSectionsAmount = null
        this.postmutationSectionsAmount = 0
    }

    // doc: sometimes we have edit form where we show preview of attachment
    // with hidden field. If mutation runs it sets it value to blank string as
    // in connect() method. To prevent this we checking if we dealing with edit from
    // where attachemnt already added.
    is_edit_form_field_display(){
        if (this.sectionId == "" && this.sectionType == "") {
            return true
        } else {
            return false
        }
    }

    // Doc: When in a form we already have sections (edit form)
    loadExistingAttachments(){
        console.log("remote_select_cheat_sheet_group_section_controller: loadExistingAttachments triggered")
        // 1.1 select all containers
        let selector = sectionCaseNestedFields
        this.fieldsContainers = [...this.sectionsAreaTarget.querySelectorAll(selector)]

        var that= this
        // 1.2 iterate thru each container
        this.fieldsContainers.filter(function (fieldsContainer) {
            // 1.3 load preview for container
            let attachmentPreviewContainer = fieldsContainer.querySelector(".section-preview")
            that.setSectionIdAndTypeBy(fieldsContainer)
            that.setLoadUrl()
            that.setPreviewContainer(fieldsContainer)
            // that.loadPreview(attachmentPreviewContainer)
            that.loadPreview()
            // Doc: prevents mutation code block from considering loaded in edit form existing attachments
            // as new added items. If we don't have this method mutation code block will add new preview attachment.
            that.clearSectionVariables()
        });
    }

    clearSectionVariables(){
        this.sectionId = ""
        this.sectionType = ""
    }

    setSectionIdAndTypeBy(fieldsContainer){
        let idFieldSelector = "linkable-id-hidden-field"
        let typeFieldSelector = "linkable-type-hidden-field"

        let sectionId = fieldsContainer.querySelector(`.${idFieldSelector}`).value
        let sectionType = fieldsContainer.querySelector(`.${typeFieldSelector}`).value
        console.log("remote_select_cheat_sheet_group_section_controller: sectionId")
        console.log(sectionId)
        console.log("remote_select_cheat_sheet_group_section_controller: sectionType")
        console.log(sectionType)

        this.sectionId = sectionId
        if (sectionType == cheatSheetClass) {
            this.sectionType = cheatSheetCase
        } else if (sectionType == cheatSheetGroupClass) {
            this.sectionType = cheatSheetGroupCase
        }
        // else if (linkAttachmentType == unitClass) {
        //     this.linkAttachmentType = unitCase
        // } else if (linkAttachmentType == algorithmClass) {
        //     this.linkAttachmentType = algorithmCase
        // }
    }
    //


    was_already_added_sections(){
        if (this.numberOfMatches() > 0) {
            console.log("remote_select_cheat_sheet_group_section_controller: Section was already added")
            // TODO: flash popup - article was already added
            return true
        } else {
            return false
        }
    }

    numberOfMatches(){
        let allSections = this.sectionsAreaTarget.querySelectorAll(sectionCaseNestedFields)
        console.log("remote_select_cheat_sheet_group_section_controller: allSections")
        console.log(allSections)

        let allSectionsArray = [...allSections]
        var that = this
        let matches = allSectionsArray.filter(function (section) {
            let idFieldSelector = "sectionable-id-hidden-field"
            let typeFieldSelector = "sectionable-type-hidden-field"

            let fieldSectionId = section.querySelector(`.${idFieldSelector}`).value
            let fieldSectionType = section.querySelector(`.${typeFieldSelector}`).value

            if (that.sectionType == cheatSheetCase) {
                that.correlatedSectionType = cheatSheetClass
            } else if (that.sectionType == cheatSheetGroupCase) {
                that.correlatedSectionType = cheatSheetGroupClass
            }
            // else if (that.linkAttachmentType == unitCase) {
            //     let correlatedLinkAttachmentType = unitClass
            // } else if (that.linkAttachmentType == algorithmCase) {
            //     let correlatedLinkAttachmentType = algorithmClass
            // }

            return (fieldSectionId == that.sectionId) && (fieldSectionType == that.correlatedSectionType)
        });
        let amount = matches.length
        return amount
    }

    setFieldsContainer(){
        let selector = sectionCaseNestedFields
        this.fieldsContainer = [...this.sectionsAreaTarget.querySelectorAll(selector)].pop()
    }

    setSectionValues(){
        this.setSectionableValues()
    }

    setSectionableValues(){
        let idField = "sectionable-id-hidden-field"
        let typeField = "sectionable-type-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.sectionId
        if (this.sectionType == articleCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = articleClass
        } else if (this.sectionType == unitCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = unitClass
        } else if (this.sectionType == cheatSheetCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = cheatSheetClass
        } else if (this.sectionType == cheatSheetGroupCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = cheatSheetGroupClass
        }

        console.log("this.fieldsContainer.querySelector(`.${idField}`).value")
        console.log("this.fieldsContainer.querySelector(`.${typeField}`).value")
        console.log(this.fieldsContainer.querySelector(`.${idField}`).value)
        console.log(this.fieldsContainer.querySelector(`.${typeField}`).value)
    }

    setPreviewContainer(fieldsContainer){
        if (typeof fieldsContainer !== "undefined") {
            this.sectionPreviewContainer = fieldsContainer.querySelector(".section-preview")
        } else {
            this.sectionPreviewContainer = this.fieldsContainer.querySelector(".section-preview")
        }
    }

    // TODO: add preload animation
    // TODO: + add animaton when we preloading in edit form
    // Load preview logic
    loadPreview(){
        // 4.3 make request
        Rails.ajax({
            type: 'GET',
            url: this.previewUrl,
            dataType: 'json',
            success: (data) => {
                console.log("remote_select_cheat_sheet_group_section_controller: Preview loaded!")
                this.preview = data.preview
                this.insertPreview()
            }
        })
    }

    setLoadUrl(){
        console.log("remote_select_cheat_sheet_group_section_controller: setLoadUrl triggered")
        console.log("remote_select_cheat_sheet_group_section_controller: this.linkAttachmentType")
        console.log(this.sectionType)

        const params = 'preview_type=cheat_sheet_group_section_preview'
        if (this.sectionType == articleCase) {
            this.previewUrl = `/article/articles/${this.sectionId}/preview?${params}`
        } else if (this.sectionType == unitCase) {
            this.previewUrl = `/unit/units/${this.sectionId}/preview?${params}`
        } else if (this.sectionType == cheatSheetCase) {
            this.previewUrl = `/cheat_sheet/cheat_sheets/${this.sectionId}/preview?${params}`
        } else if (this.sectionType == cheatSheetGroupCase) {
            this.previewUrl = `/cheat_sheet_group/cheat_sheet_groups/${this.sectionId}/preview?${params}`
        } else {
            console.log("Can not set load url, case not programmed")
        }
        // } else if (this.sectionType == unitCase) {
        //     const params = 'preview_type=cheat_sheet_from_notes_link_attachment_preview'
        //     this.previewUrl = `/unit/units/${this.linkAttachmentId}/preview?${params}`
        // } else if (this.sectionType == algorithmCase) {
        //     const params = 'preview_type=cheat_sheet_from_notes_link_attachment_preview'
        //     this.previewUrl = `/algorithm/algorithms/${this.linkAttachmentId}/preview?${params}`
        // } else {
        //     console.log("Can not set load url, case not programmed")
        // }
    }

    insertPreview(){
        // // Case 1.When we have load on edit form
        // if (typeof container !== "undefined") {
        //     container.insertAdjacentHTML('beforeend', this.preview)
        //
        // // Case 2.When we on new form
        // } else {
        //     this.attachmentPreviewContainer.insertAdjacentHTML('beforeend', this.preview)
        // }
        this.sectionPreviewContainer.insertAdjacentHTML('beforeend', this.preview)
    }

    // Technologies search modal logic
    resetSearchForm(){
        // multiple instances on the same page
        this.searchInstructionsInstanceTargets.forEach(target => {
            var searchInstructionsController = this.application.getControllerForElementAndIdentifier(target, 'search_instructions')
            searchInstructionsController.resetForm()
        });
    }

    removeModal(){
        const selectInstructionModalController = this.application.getControllerForElementAndIdentifier(this.instructionModalInstanceTarget, 'select_instruction_modal')
        selectInstructionModalController.close()
    }

}