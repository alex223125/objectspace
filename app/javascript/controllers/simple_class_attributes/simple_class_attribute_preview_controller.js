// responsibility zone - load preview if edit for when we already have article
import { Controller } from '@hotwired/stimulus';

const regularFieldsFormCase = "regular_fields_form"
const simpleClassAttributesListCase = "simple_class_attributes_list"

export default class extends Controller {

    static values = {
        previewType: String,
        articleId: String
    }

    static targets = [
        'attributeIdHiddenField',
        'attributePreviewContainer'
    ]

    initialize() {
        console.log("Attribute preview controller initialized")
    }

    connect() {
        console.log("Attribute preview controller connected")
        this.initializePreview();
    }

    disconnect() {
        console.log("Attribute preview controller disconnected")
    }


    // PRIVATE

    initializePreview(){
        // console.log("11111111111111111111111111111")
        // console.log(this.hasAttributeIdHiddenFieldTarget)
        // console.log(this.hasArticleIdValue)

        if (this.hasAttributeIdHiddenFieldTarget || this.hasArticleIdValue) {
            this.loadPreview()
        }
    }

    // TODO: add reload button and loading icon during load
    loadPreview(){
        // let articleId = this.attributeIdHiddenFieldTarget.value
        let articleId = this.articleId()
        let previewType = this.previewType()
        let url = `/article/articles/${articleId}/preview?preview_type=${previewType}`

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

    articleId(){
        if (this.previewTypeValue == regularFieldsFormCase) {
            return this.attributeIdHiddenFieldTarget.value
        } else if (this.previewTypeValue == simpleClassAttributesListCase) {
            return this.articleIdValue
        }
    }

    previewType(){
        if (this.previewTypeValue == regularFieldsFormCase) {
            return "basic_preview"
        } else if (this.previewTypeValue == simpleClassAttributesListCase) {
            return "small_line_preview"
        }
    }

    insertPreview(data){
        this.attributePreviewContainerTarget.insertAdjacentHTML('beforeend', data.preview)
    }

}