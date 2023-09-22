// doc: responsibility zone - load preview of article and other types of attachments on click during reading of algorithm
import { Controller } from '@hotwired/stimulus';

const articleCase = "article"

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
        var url = this.setLoadUrl()

        // 1.set load animation
        this.toggleLoadingIndicator("show")

        // 2 make request
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("View loaded!")
                // console.log(data.preview)
                // 3.disable load animation
                this.toggleLoadingIndicator("hide")
                this.insertView(data)
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            },
            error: (response) => {
                console.log("View not loaded!")
                console.log(response)
                this.toggleLoadingIndicator("hide")
                this.toggleRetryCard("show")
            }

        })
    }

    setLoadUrl(){
        // 4.2 stet variables for substep inputs field
        if (this.attachmentType == articleCase) {
            var params = 'type=regular'
            var url = `/article/articles/${this.attachmentUuid}/dynamic_view?${params}`
        } else {
            console.log("Can not set load url, case not programmed")
        }
        return url;
    }

    insertView(data){
        this.containerTarget.innerHTML = "";
        this.containerTarget.insertAdjacentHTML('beforeend', data.dynamic_view)
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