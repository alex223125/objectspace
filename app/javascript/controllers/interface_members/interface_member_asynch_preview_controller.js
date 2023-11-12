// responsibility zone - load preview if edit for when we already have article
import { Controller } from '@hotwired/stimulus';

const regularFieldsFormCase = "regular_fields_form"
// const simpleClassAttributesListCase = "simple_class_attributes_list"

// Member type cases:
const unitTechTypeCase = "Units::Unit"
const algorithmTechTypeCase = "Algorithms::Algorithm"

export default class extends Controller {

    static values = {
        previewType: String
    }

    static targets = [
        'memberableTypeHiddenField',
        'memberableIdHiddenField',
        'interfaceMemberPreviewContainer'
    ]

    initialize() {
        console.log("Interface member asynch preview controller initialized")
    }

    connect() {
        console.log("Interface member asynch preview controller connected")
        this.initializePreview();
    }

    disconnect() {
        console.log("Interface member asynch preview controller disconnected")
    }


    // PRIVATE

    initializePreview(){
        // console.log("22222222222222222222222222222222")
        // console.log(this.hasMemberableTypeHiddenFieldTarget)
        // console.log(this.hasMemberableIdHiddenFieldTarget)
        // console.log(this.hasArticleIdValue)

        if (this.hasMemberableTypeHiddenFieldTarget && this.hasMemberableIdHiddenFieldTarget) {
            this.loadPreview()
        }
    }

    // TODO: add reload button and loading icon during load
    // TODO: plus retry button
    loadPreview(){
        // let articleId = this.attributeIdHiddenFieldTarget.value
        this.setTechnologyId()
        this.setTechnologyType()
        this.setPreviewType()
        this.setPreviewUrl()

        let url = this.previewUrl
        console.log("URL URL URL")
        console.log(url)

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Interface member preview loaded!")
                console.log(data.preview)
                this.insertPreview(data)
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            }
        })
    }

    setPreviewUrl() {
        if (this.technologyType == unitTechTypeCase) {
            this.previewUrl = `/unit/units/${this.technologyId}/preview?type=${this.previewType}`
        } else if (this.technologyType == algorithmTechTypeCase) {
            this.previewUrl =  `/algorithm/algorithms/${this.technologyId}/preview?type=${this.previewType}`
        }
    }

    setTechnologyId(){
        this.technologyId = this.memberableIdHiddenFieldTarget.value
    }

    setTechnologyType(){
        this.technologyType = this.memberableTypeHiddenFieldTarget.value
    }

    setPreviewType(){
        if (this.previewTypeValue == regularFieldsFormCase) {
            this.previewType = "basic_preview"
        }
    }

    insertPreview(data){
        this.interfaceMemberPreviewContainerTarget.insertAdjacentHTML('beforeend', data.preview)
    }

}
