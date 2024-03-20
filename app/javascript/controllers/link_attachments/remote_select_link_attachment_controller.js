// doc: responsibility zone: select technology as attachment
import { Controller } from '@hotwired/stimulus'
import { useMutation } from 'stimulus-use'

const linkAttachmentCaseNestedFields = '.nested-fields-link-attachment'

const articleCase = "article"
const articleClass = "Articles::Article"
const unitCase = "unit"
const unitClass = "Units::Unit"

const algorithmCase = "algorithm"
const algorithmClass = "Algorithms::Algorithm"

export default class extends Controller {
    static targets = [
        'searchInstructionsInstance',
        'instructionModalInstance',

        'linkAttachmentsArea',
        'addLinkAttachmentOriginalButton',
    ]

    initialize(){
    }

    connect() {
        console.log("remote_select_link_attachment_controller connected")

        // General variables for all cases
        this.linkAttachmentId = ""
        this.linkAttachmentType = ""

        this.addMutationListener()
        this.loadExistingAttachments()
    }

    disconnect() {
        console.log("remote_select_link_attachment_controller disconnected")
    }


    // Callbacks
    mutate(entries) {
        console.log(`remote_select_link_attachment_controller: mutation triggered`)

        if (this.is_edit_form_field_display()) {
            console.log("remote_select_link_attachment_controller: Edit form field display mutation")
            return
        }

        var nestedFields = linkAttachmentCaseNestedFields
        this.afterClickAttachmentsAmount = this.linkAttachmentsAreaTarget.querySelectorAll(nestedFields).length

        console.log("remote_select_link_attachment_controller: this.currentAttachmentsAmount")
        console.log(this.currentAttachmentsAmount)
        console.log("remote_select_link_attachment_controller: this.afterClickAttachmentsAmount")
        console.log(this.afterClickAttachmentsAmount)

        // Doc: Case 2: Should go in code before case 1. This is the case when we removed
        // some of the attachments and have disbalanse in this.postmutationAttachmentsAmount variable
        // so we calibrating it back to normal situation
        if (this.afterClickAttachmentsAmount < this.postmutationAttachmentsAmount){
            this.postmutationAttachmentsAmount = this.afterClickAttachmentsAmount
        }

        // Doc: Case 1. When we increase amount of attachments
        var changedAmount = (this.currentAttachmentsAmount + 1)
        if ((changedAmount == this.afterClickAttachmentsAmount) && (changedAmount != this.postmutationAttachmentsAmount)) {
            console.log("remote_select_link_attachment_controller: New Attachment added!");
            this.setFieldsContainer()
            this.setAttachmentValues()
            this.setAttachmentPreviewContainer()
            this.setLoadUrl()
            this.loadPreview()
            this.postmutationAttachmentsAmount = changedAmount
        } else {
            console.log("remote_select_link_attachment_controller: Amount not changed or error");
        }
    }

    // PUBLIC
    selectLinkAttachment(event){
        this.linkAttachmentId = event.currentTarget.dataset.linkattachmentid
        this.linkAttachmentType = event.currentTarget.dataset.linkattachmenttype

        console.log("remote_select_link_attachment: linkAttachmentId and linkAttachmentType")
        console.log(this.linkAttachmentId)
        console.log(this.linkAttachmentType)

        this.resetSearchForm()
        this.removeModal()

        this.prevent_from_adding_already_added_attachments()

        this.addLinkAttachment()

        // if (this.linkAttachmentType == "article") {
        //     this.addArticleAttachment()
        // }
    }

    // PRIVATE

    addMutationListener() {
        console.log("remote_select_link_attachment: mutation listener added")
        // mutation is used to check if new attachment is added on ui side
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree: true})
        this.afterClickAttachmentsAmount = null
        this.currentAttachmentsAmount = null
        this.postmutationAttachmentsAmount = 0
    }

    // doc: sometimes we have edit form where we show preview of attachment
    // with hidden field. If mutation runs it sets it value to blank string as
    // in connect() method. To prevent this we checking if we dealing with edit from
    // where attachemnt already added.
    is_edit_form_field_display(){
        if (this.linkAttachmentId == "" && this.linkAttachmentType == "") {
            return true
        } else {
            return false
        }
    }

    // Doc: When in a form we already have attached attachments (edit for for example)
    loadExistingAttachments(){
        console.log("remote_select_attachment: loadExistingAttachments triggered")
        // 1.1 select all containers
        let selector = linkAttachmentCaseNestedFields
        this.fieldsContainers = [...this.linkAttachmentsAreaTarget.querySelectorAll(selector)]

        var that= this
        // 1.2 iterate thru each container
        this.fieldsContainers.filter(function (fieldsContainer) {
            // 1.3 load preview for container
            let attachmentPreviewContainer = fieldsContainer.querySelector(".link-attachment-preview")
            that.setAttachmentIdAndTypeBy(fieldsContainer)
            that.setLoadUrl()
            that.setAttachmentPreviewContainer(fieldsContainer)
            // that.loadPreview(attachmentPreviewContainer)
            that.loadPreview()
            // Doc: prevents mutation code block from considering loaded in edit form existing attachments
            // as new added items. If we don't have this method mutation code block will add new preview attachment.
            that.cleaAttachmentVariables()
        });
    }

    cleaAttachmentVariables(){
        this.linkAttachmentId = ""
        this.linkAttachmentType = ""
    }

    setAttachmentIdAndTypeBy(fieldsContainer){
        let idFieldSelector = "linkable-id-hidden-field"
        let typeFieldSelector = "linkable-type-hidden-field"

        let linkAttachmentId = fieldsContainer.querySelector(`.${idFieldSelector}`).value
        let linkAttachmentType = fieldsContainer.querySelector(`.${typeFieldSelector}`).value
        console.log("remote_select_link_attachment: linkAttachmentId")
        console.log(linkAttachmentId)
        console.log("remote_select_link_attachment_controller: attachmentType")
        console.log(linkAttachmentType)

        this.linkAttachmentId = linkAttachmentId
        if (linkAttachmentType == articleClass) {
            this.linkAttachmentType = articleCase
        } else if (linkAttachmentType == unitClass) {
            this.linkAttachmentType = unitCase
        } else if (linkAttachmentType == algorithmClass) {
            this.linkAttachmentType = algorithmCase
        }
    }
    //


    prevent_from_adding_already_added_attachments(){
        if (this.numberOfMatches() > 0) {
            console.log("remote_select_link_attachment_controller: LinkAttachment was already added")
            // TODO: flash popup - article was already added
            return
        } else {
            // do nothing
        }
    }

    numberOfMatches(){
        let allAttachments = this.linkAttachmentsAreaTarget.querySelectorAll(linkAttachmentCaseNestedFields)
        console.log("allAttachments")
        console.log(allAttachments)

        let allAttachmentsArray = [...allAttachments]
        var that = this
        let matches = allAttachmentsArray.filter(function (attachment) {
            let idFieldSelector = "linkable-id-hidden-field"
            let typeFieldSelector = "linkable-type-hidden-field"

            let fieldLinkAttachmentId = attachment.querySelector(`.${idFieldSelector}`).value
            let fieldLinkAttachmentType = attachment.querySelector(`.${typeFieldSelector}`).value

            if (that.linkAttachmentType == articleCase) {
                var correlatedLinkAttachmentType = articleClass
            } else if (that.linkAttachmentType == unitCase) {
                var correlatedLinkAttachmentType = unitClass
            } else if (that.linkAttachmentType == algorithmCase) {
                var correlatedLinkAttachmentType = algorithmClass
            }

            return (fieldLinkAttachmentId == that.linkAttachmentId) && (fieldLinkAttachmentType == correlatedLinkAttachmentType)
        });
        let amount = matches.length
        return amount
    }

    addLinkAttachment(){
        //Calculate amount of substep before adding new substep
        var nestedFields = linkAttachmentCaseNestedFields
        this.currentAttachmentsAmount = this.linkAttachmentsAreaTarget.querySelectorAll(nestedFields).length
        console.log("remote_select_link_attachment_controller: current attachments:")
        console.log(this.currentAttachmentsAmount)

        // 3.click hidden button under previous selected step
        console.log("addLinkAttachmentOriginalButtonTarget.click() fired")
        this.addLinkAttachmentOriginalButtonTarget.click()
    }

    setFieldsContainer(){
        let selector = linkAttachmentCaseNestedFields
        this.fieldsContainer = [...this.linkAttachmentsAreaTarget.querySelectorAll(selector)].pop()
    }

    setAttachmentValues(){
        this.setLinkableValues()
    }

    setLinkableValues(){
        let idField = "linkable-id-hidden-field"
        let typeField = "linkable-type-hidden-field"

        this.fieldsContainer.querySelector(`.${idField}`).value = this.linkAttachmentId
        if (this.linkAttachmentType == articleCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = articleClass
        } else if (this.linkAttachmentType == unitCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = unitClass
        } else if (this.linkAttachmentType == algorithmCase) {
            this.fieldsContainer.querySelector(`.${typeField}`).value = algorithmClass
        }

        console.log("this.fieldsContainer.querySelector(`.${idField}`).value")
        console.log("this.fieldsContainer.querySelector(`.${typeField}`).value")
        console.log(this.fieldsContainer.querySelector(`.${idField}`).value)
        console.log(this.fieldsContainer.querySelector(`.${typeField}`).value)
    }

    setAttachmentPreviewContainer(fieldsContainer){
        if (typeof fieldsContainer !== "undefined") {
            this.attachmentPreviewContainer = fieldsContainer.querySelector(".link-attachment-preview")
        } else {
            this.attachmentPreviewContainer = this.fieldsContainer.querySelector(".link-attachment-preview")
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
                console.log("Preview loaded!")
                this.preview = data.preview
                this.insertPreview()
            }
        })
    }

    setLoadUrl(){
        console.log("remote_select_link_attachment_controller: setLoadUrl triggered")
        console.log("remote_select_link_attachment_controller: this.linkAttachmentType")
        console.log(this.linkAttachmentType)

        if (this.linkAttachmentType == articleCase) {
            const params = 'preview_type=cheat_sheet_from_notes_link_attachment_preview'
            this.previewUrl = `/article/articles/${this.linkAttachmentId}/preview?${params}`
        } else if (this.linkAttachmentType == unitCase) {
            const params = 'preview_type=cheat_sheet_from_notes_link_attachment_preview'
            this.previewUrl = `/unit/units/${this.linkAttachmentId}/preview?${params}`
        } else if (this.linkAttachmentType == algorithmCase) {
            const params = 'preview_type=cheat_sheet_from_notes_link_attachment_preview'
            this.previewUrl = `/algorithm/algorithms/${this.linkAttachmentId}/preview?${params}`
        } else {
            console.log("Can not set load url, case not programmed")
        }
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
        this.attachmentPreviewContainer.insertAdjacentHTML('beforeend', this.preview)
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