// doc:
// responsibility zone #1 - load preview of article and other types of attachments
// on click during reading of algorithm
// responsibility zone #2 - load preview of articles,units,algorithms (link_attachments) on CheatSheet page
import { Controller } from '@hotwired/stimulus';

const articleCase = "article"
const unitCase = "unit"
const algorithmCase = "algorithm"

export default class extends Controller {

    static targets = [
        'container',
        'loadingIndicator',
        'retryCard',
        'modalHiddenButton'
    ]

    initialize() {
        console.log("attachment_preview_controller controller initialized")
    }

    connect() {
        console.log("attachment_preview_controller controller connected")
    }

    disconnect() {
        console.log("attachment_preview_controller controller disconnected")
    }

    // PUBLIC
    openModal(event){
        event.preventDefault()
        this.modalHiddenButtonTarget.click()

        console.log("Attachment data:")
        console.log(event)
        let dataset = event.target.dataset
        this.setAttachmentData(dataset)

        this.removePreviouslyLoadedAttachment()
        this.loadView()
    }

    retryLoad(){
        this.toggleRetryCard("hide")
        this.loadView()
    }


    // PRIVATE
    setAttachmentData(dataset){
        this.attachmentType = dataset.attachmentType
        this.attachmentUuid = dataset.attachmentUuid
    }

    loadView(){
        this.toggleRetryCard("hide")
        var url = this.setLoadUrl()

        // 1.set load animation
        this.toggleLoadingIndicator("show")

        // 2 make request
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("attachment_preview_controller: View loaded!")
                // console.log(data.preview)
                // 3.disable load animation
                this.toggleLoadingIndicator("hide")
                this.insertView(data)
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            },
            error: (response) => {
                console.log("attachment_preview_controller: View not loaded!")
                console.log(response)
                this.toggleLoadingIndicator("hide")
                this.toggleRetryCard("show")
            }

        })
    }

    setLoadUrl() {
        // 4.2 stet variables for substep inputs field
        if (this.attachmentType == articleCase) {
            var params = 'type=regular'
            var url = `/article/articles/${this.attachmentUuid}/view?${params}`
        } else if (this.attachmentType == unitCase) {
            var params = 'type=regular'
            var url = `/unit/units/${this.attachmentUuid}/view?${params}`
        } else if (this.attachmentType == algorithmCase) {
            var params = 'type=regular'
            var url = `/algorithm/algorithms/${this.attachmentUuid}/view?${params}`
        } else {
            console.log("Can not set load url, case not programmed")
        }
        return url;
    }

    removePreviouslyLoadedAttachment() {
        console.log("attachment_preview_controller: previously loaded attachment removed")
        this.containerTarget.innerHTML = ""
    }

    insertView(data){
        this.containerTarget.innerHTML = ""
        this.containerTarget.insertAdjacentHTML('beforeend', data.view)
        // this.containerTarget.focus()
    }


    toggleLoadingIndicator(action){
        if (action == "hide"){
            this.loadingIndicatorTarget.style.display = 'none'
        } else if (action == "show") {
            this.loadingIndicatorTarget.style.display = ''
        }
    }

    toggleRetryCard(action){
        if (action == "hide"){
            this.retryCardTarget.style.display = 'none'
        } else if (action == "show") {
            this.retryCardTarget.style.display = ''
        }
    }

}