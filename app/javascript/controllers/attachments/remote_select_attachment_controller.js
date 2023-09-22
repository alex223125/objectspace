// doc: responsibility zone: select technology as attachment
import { Controller } from '@hotwired/stimulus'
import { useMutation } from 'stimulus-use'

const attachmentCaseNestedFields = '.nested-fields-attachment'

const attachmentAdditionCase = "algorithm_form_attachment_addition";

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
        // this.selectedItemsFormInput();

        // General variables for all cases
        this.attachmentId = ""
        this.attachmentType = ""

        console.log("SELECT TYPE VALUE")
        console.log(this.selectTypeValue)

        if (this.selectTypeValue == attachmentAdditionCase) {
            console.log("mutation listener added")
            // mutation is used to check if new interface member is added on ui side
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
        if (this.selectTypeValue == attachmentAdditionCase) {
            console.log(`mutation for ${attachmentAdditionCase} case triggered`)
            var nestedFields = attachmentCaseNestedFields
            this.afterClickAttachmentsAmount = this.attachmentsAreaTarget.querySelectorAll(nestedFields).length

            console.log("this.currentAttachmentsAmount")
            console.log(this.currentAttachmentsAmount)
            console.log("this.afterClickAttachmentsAmount")
            console.log(this.afterClickAttachmentsAmount)

            // Case 2: Should go in code before case 1. This is the case when we removed
            // some of the attachments and have disbalanse in this.postmutationAttachmentsAmount variable
            // so we calibrating it back to normal situation
            if (this.afterClickAttachmentsAmount < this.postmutationAttachmentsAmount){
                this.postmutationAttachmentsAmount = this.afterClickAttachmentsAmount
            }

            // Case 1. When we increase amount if attachments
            var changedAmount = (this.currentAttachmentsAmount + 1)
            if ((changedAmount == this.afterClickAttachmentsAmount) && (changedAmount != this.postmutationAttachmentsAmount)) {
                console.log("New Attachment added!");
                this.setFieldsContainer()
                this.setAttachmentValues()
                this.setAttachmentPreviewContainer()
                this.setLoadUrl()
                this.loadPreview()
                this.postmutationAttachmentsAmount = changedAmount
            } else {
                console.log("Amount not changed or error");
            }

        }
    }

    // PUBLIC
    selectAttachment(event){
        this.attachmentId = event.currentTarget.dataset.attachmentid
        this.attachmentType = event.currentTarget.dataset.attachmenttype

        console.log("attachmentId and attachmentType")
        console.log(this.attachmentId)
        console.log(this.attachmentType)

        this.resetSearchForm()
        this.removeModal()

        if (this.numberOfMatches() > 0) {
            console.log("Attachment was already added")
            // TODO: flash popup - article was already added
            return
        } else {
            // do nothing
        }

        if (this.attachmentType == "article") {
            this.addArticleAttachment()
        }
    }

    // PRIVATE

    // when in a form we already have attached attachments
    loadExistingAttachments(){
        // 1.select all containers
        let selector = attachmentCaseNestedFields
        this.fieldsContainers = [...this.attachmentsAreaTarget.querySelectorAll(selector)]

        var that = this
        // 2.iterate thru each container
        this.fieldsContainers.filter(function (fieldsContainer) {
            // 3. load preview for container
            let attachmentPreviewContainer = fieldsContainer.querySelector(".attachment-preview")
            that.setAttachmentIdAndTypeBy(fieldsContainer)
            that.setLoadUrl()
            that.loadPreview(attachmentPreviewContainer)
        });
    }

    setAttachmentIdAndTypeBy(fieldsContainer){
        let idFieldSelector = "attachable-id-hidden-field"
        let typeFieldSelector = "attachable-type-hidden-field"

        let attachmentId = fieldsContainer.querySelector(`.${idFieldSelector}`).value
        let attachmentType = fieldsContainer.querySelector(`.${typeFieldSelector}`).value

        this.attachmentId = attachmentId
        if (attachmentType == articleClass) {
            this.attachmentType =  articleCase
        }
    }
    //

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
        if (this.selectTypeValue == attachmentAdditionCase) {
            this.setAttachableValues()
        }
    }

    setAttachableValues(){
        let idField = "attachable-id-hidden-field"
        let typeField = "attachable-type-hidden-field"

        if (this.attachmentType == articleCase) {
            this.fieldsContainer.querySelector(`.${idField}`).value = this.attachmentId
            this.fieldsContainer.querySelector(`.${typeField}`).value = articleClass
        }

    }

    setAttachmentPreviewContainer(){
        if (this.selectTypeValue == attachmentAdditionCase) {
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
            if (this.selectTypeValue == attachmentAdditionCase) {
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