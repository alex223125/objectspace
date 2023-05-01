// responsibility zone - render preview of specific Unit or Algorithm as substep during algorithm creation
import { Controller } from '@hotwired/stimulus'
import { useTargetMutation } from 'stimulus-use'

export default class extends Controller {
    static targets = ['algorithmId', 'unitId']

    connect() {
        console.log("Substep preview controller connected")

        // this.submitHandler = this.doTheThing.bind(this)
        // this.algorithmIdTarget.addEventListener('change', this.submitHandler)
        // this.unitIdTarget.addEventListener('change', this.submitHandler)

        // mutation is used to check if instruction id is added to hidden input
        // useMutation(this, {attributes: true, childList: false, characterData: false, subtree:true})
        useTargetMutation(this)
    }

    disconnect() {
        console.log("Substep preview  controller disconnected")

        // this.element.removeEventListener('submit', this.submitHandler)
    }

    // mutate(entries) {
    //     console.log("Mutation happend!")
    //     this.renderPreview()
    // }

    // doTheThing(evt) {
    //     // ...
    //     console.log("renderPreview is fired")
    // }

    unitIdTargetChanged(element) {
        console.log("Mutation happend!")
        this.renderPreview()
    }


    renderPreview(event) {
        console.log("renderPreview is fired")
        // 1 on input change

        console.log("Targets")
        // console.log(this.algorithmIdTarget)
        console.log(this.unitIdTarget)
        //
        // if event.currentTarget.dataset.instructionid
        //
        // let url = `/improvements?unit_version_id=${this.unitVersionId}&page=${this.page}`
        //
        // Rails.ajax({
        //     type: 'GET',
        //     url: url,
        //     dataType: 'json',
        //     success: (data) => {
        //         console.log("Preview loaded!")
        //         console.log(data.preview)
        //         // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
        //         // this.page = this.page + 1
        //         // this.totalPages = data.pagination.pages
        //     }
        // })

        // make request to api for record and get response html as string
        // place html in div
    }



    // showTab() {
    // }

}
