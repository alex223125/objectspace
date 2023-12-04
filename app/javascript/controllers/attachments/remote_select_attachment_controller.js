// doc: responsibility zone: select technology as attachment
import { Controller } from '@hotwired/stimulus'
import { useMutation } from 'stimulus-use'

const attachmentCaseNestedFields = '.nested-fields-attachment'

const algorithmFormAttachmentAdditionCase = "algorithm_form_attachment_addition";
const unitVersionFormAttachmentAdditionCase = "unit_version_form_attachment_addition";
const articleVersionFormAttachmentAdditionCase = "article_version_form_attachment_addition";

const articleCase = "article";
const articleClass = "Articles::Article"

export default class extends Controller {
    static targets = [
        'itemsModalInput',
        'attachmentsFormInput',

        'searchInstructionsInstance',
        'instructionModalInstance',

        'attachmentsArea',

        'addArticleAttachmentOriginalButton',

        'attachableTypeHiddenField',
        'attachableIdHiddenField'
]

    static values = {
        selectType: String
    }

    initialize(){
    }

    connect() {
        console.log("remote_select_attachment_controller connected")

        // General variables for all cases
        this.attachmentId = ""
        this.attachmentType = ""

        console.log("remote_select_attachment_controller: select type value")
        console.log(this.selectTypeValue)

        if (this.selectTypeValue == algorithmFormAttachmentAdditionCase ||
            this.selectTypeValue == unitVersionFormAttachmentAdditionCase ||
            this.selectTypeValue == articleVersionFormAttachmentAdditionCase) {
            console.log("remote_select_attachment: mutation listener added")
            // mutation is used to check if new attachment is added on ui side
            useMutation(this, {attributes: false, childList: true, characterData: false, subtree: true})
            this.afterClickAttachmentsAmount = null
            this.currentAttachmentsAmount = null
            this.postmutationAttachmentsAmount = 0
        }

        this.loadExistingAttachments()
    }

    disconnect() {
        console.log("remote_select_attachment_controller disconnected")
    }

    // Callbacks
    mutate(entries) {
        if (this.selectTypeValue == algorithmFormAttachmentAdditionCase ||
            this.selectTypeValue == unitVersionFormAttachmentAdditionCase ||
            this.selectTypeValue == articleVersionFormAttachmentAdditionCase) {
            console.log(`remote_select_attachment: mutation for ${this.selectTypeValue} case triggered`)

            if (this.is_edit_form_field_display()) {
                console.log("remote_select_attachment: Edit form filed disaply mutation")
                return
            }

            var nestedFields = attachmentCaseNestedFields
            this.afterClickAttachmentsAmount = this.attachmentsAreaTarget.querySelectorAll(nestedFields).length

            console.log("remote_select_attachment: this.currentAttachmentsAmount")
            console.log(this.currentAttachmentsAmount)
            console.log("remote_select_attachment: this.afterClickAttachmentsAmount")
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
                console.log("remote_select_attachment: New Attachment added!");
                this.setFieldsContainer()
                this.setAttachmentValues()
                this.setAttachmentPreviewContainer()
                this.setLoadUrl()
                this.loadPreview()
                this.postmutationAttachmentsAmount = changedAmount
            } else {
                console.log("remote_select_attachment: Amount not changed or error");
            }

        }
    }

    // PUBLIC
    selectAttachment(event){
        this.attachmentId = event.currentTarget.dataset.attachmentid
        this.attachmentType = event.currentTarget.dataset.attachmenttype

        console.log("remote_select_attachment: attachmentId and attachmentType")
        console.log(this.attachmentId)
        console.log(this.attachmentType)

        this.resetSearchForm()
        this.removeModal()

        this.prevent_from_adding_already_added_attachments()

        if (this.attachmentType == "article") {
            this.addArticleAttachment()
        }
    }

    // PRIVATE

    // doc: sometimes we have edit form where we show preview of attachment
    // with hidden field. If mutation runs it sets it value to blank string as
    // in connect() method. To prevent this we checking if we dealing with edit from
    // where attachemnt already added.
    is_edit_form_field_display(){
        if (this.attachmentId == "" && this.attachmentType == "") {
            return true
        } else {
            return false
        }
    }

    // Doc: When in a form we already have attached attachments (edit for for example)
    loadExistingAttachments(){
        console.log("remote_select_attachment: loadExistingAttachments triggered")
        // 1.1 select all containers
        let selector = attachmentCaseNestedFields
        this.fieldsContainers = [...this.attachmentsAreaTarget.querySelectorAll(selector)]

        var that= this
        // 1.2 iterate thru each container
        this.fieldsContainers.filter(function (fieldsContainer) {
            // 1.3 load preview for container
            let attachmentPreviewContainer = fieldsContainer.querySelector(".attachment-preview")
            that.setAttachmentIdAndTypeBy(fieldsContainer)
            that.setLoadUrl()
            that.loadPreview(attachmentPreviewContainer)
            // Doc: prevents mutation code block from considering loaded in edit form existing attachments
            // as new added items. If we don't have this method mutation code block will add new preview attachment.
            that.cleaAttachmentVariables()
        });
    }

    cleaAttachmentVariables(){
        this.attachmentId = ""
        this.attachmentType = ""
    }

    setAttachmentIdAndTypeBy(fieldsContainer){
        let idFieldSelector = "attachable-id-hidden-field"
        let typeFieldSelector = "attachable-type-hidden-field"

        let attachmentId = fieldsContainer.querySelector(`.${idFieldSelector}`).value
        let attachmentType = fieldsContainer.querySelector(`.${typeFieldSelector}`).value
        console.log("remote_select_attachment: attachmentId")
        console.log(attachmentId)
        console.log("remote_select_attachment: attachmentType")
        console.log(attachmentType)

        this.attachmentId = attachmentId
        if (attachmentType == articleClass) {
            this.attachmentType = articleCase
        }
    }
    //


    prevent_from_adding_already_added_attachments(){
        if (this.numberOfMatches() > 0) {
            console.log("Attachment was already added")
            // TODO: flash popup - article was already added
            return
        } else {
            // do nothing
        }
    }

    numberOfMatches(){
        let allAttachments = this.attachmentsAreaTarget.querySelectorAll(attachmentCaseNestedFields)
        console.log("allAttachments")
        console.log(allAttachments)

        let allAttachmentsArray = [...allAttachments]
        var that = this
        let matches = allAttachmentsArray.filter(function (attachment) {
            if (that.attachmentType == articleCase){
                let idFieldSelector = "attachable-id-hidden-field"
                let typeFieldSelector = "attachable-type-hidden-field"

                let attachmentId = attachment.querySelector(`.${idFieldSelector}`).value
                let attachmentType = attachment.querySelector(`.${typeFieldSelector}`).value

                return (attachmentId == that.attachmentId) && (attachmentType == articleClass)
            }
        });
        let amount = matches.length
        return amount
    }

    addArticleAttachment(){
        //Calculate amount of substep before adding new substep
        var nestedFields = attachmentCaseNestedFields
        this.currentAttachmentsAmount = this.attachmentsAreaTarget.querySelectorAll(nestedFields).length
        console.log("current attachments:")
        console.log(this.currentAttachmentsAmount)

        // 3.click hidden button under previous selected step
        console.log("addArticleAttachmentOriginalButtonTarget.click() fired")
        this.addArticleAttachmentOriginalButtonTarget.click()
    }

    setFieldsContainer(){
        let selector = attachmentCaseNestedFields
        this.fieldsContainer = [...this.attachmentsAreaTarget.querySelectorAll(selector)].pop()
    }

    setAttachmentValues(){
        if (this.selectTypeValue == algorithmFormAttachmentAdditionCase ||
            this.selectTypeValue == unitVersionFormAttachmentAdditionCase ||
            this.selectTypeValue == articleVersionFormAttachmentAdditionCase) {
            this.setAttachableValues()
        }
    }

    setAttachableValues(){
        let idField = "attachable-id-hidden-field"
        let typeField = "attachable-type-hidden-field"

        if (this.attachmentType == articleCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.attachmentId
            this.fieldsContainer.querySelector(`.${typeField}`).value = articleClass

            console.log("this.fieldsContainer.querySelector(`.${idField}`).value")
            console.log("this.fieldsContainer.querySelector(`.${typeField}`).value")
            console.log(this.fieldsContainer.querySelector(`.${idField}`).value)
            console.log(this.fieldsContainer.querySelector(`.${typeField}`).value)
        }

    }

    setAttachmentPreviewContainer(){
        if (this.selectTypeValue == algorithmFormAttachmentAdditionCase ||
            this.selectTypeValue == unitVersionFormAttachmentAdditionCase ||
            this.selectTypeValue == articleVersionFormAttachmentAdditionCase) {
            this.attachmentPreviewContainer = this.fieldsContainer.querySelector(".attachment-preview")
        }
    }


    // TODO: add preload animation
    // TODO: + add animaton when we preloading in edit form
    // Load preview logic
    loadPreview(container){
        // 4.3 make request
        Rails.ajax({
            type: 'GET',
            url: this.previewUrl,
            dataType: 'json',
            success: (data) => {
                console.log("Preview loaded!")
                this.preview = data.preview
                this.insertPreview(container)
            }
        })
    }

    setLoadUrl(){
        console.log("remote_select_attachment: setLoadUrl triggered")
        console.log("remote_select_attachment: this.attachmentType")
        console.log(this.attachmentType)
        if (this.attachmentType == articleCase) {
            const params = 'preview_type=algorithm_step_attachment_preview'
            this.previewUrl = `/article/articles/${this.attachmentId}/preview?${params}`
        } else {
            console.log("Can not set load url, case not programmed")
        }
    }

    insertPreview(container){
        if (typeof container !== "undefined") {
            container.insertAdjacentHTML('beforeend', this.preview)
        } else {
            if (this.selectTypeValue == algorithmFormAttachmentAdditionCase ||
                this.selectTypeValue == unitVersionFormAttachmentAdditionCase ||
                this.selectTypeValue == articleVersionFormAttachmentAdditionCase) {
                this.attachmentPreviewContainer.insertAdjacentHTML('beforeend', this.preview)
            }
        }
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