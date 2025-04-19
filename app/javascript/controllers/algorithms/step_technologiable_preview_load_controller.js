// DOC: responsibility zone
// 1) to load preview for attached technologiable in algorithm creation from when we have error message and form reloads
// 2) When we have edit from of algorithm and we need to load technologiable which already attached to wrapper step

import { Controller } from "@hotwired/stimulus"


const articleCase = "Articles::Article"
const unitCase = "Units::Unit"
const algorithmCase = "Algorithms::Algorithm"
const cheatSheetCase = "CheatSheets::CheatSheet"
const cheatSheetGroupCase = "CheatSheetGroups::CheatSheetGroup"

export default class extends Controller {

    static targets = [
        'previewContainer',
        'technologiableType',
        'technologiableId'
    ];

    static values = {
        selectType: String
    }

    initialize() {
        console.log("step_technologiable_preview_load_controller initialized")
        this.loadPreview()
    }

    connect() {
        console.log("step_technologiable_preview_load_controller: connected")
    }

    disconnect() {
        console.log("step_technologiable_preview_load_controller: disconnected")
    }



    // PRIVATE
    getTechnologiableParams(){
        this.technologiableType  = this.technologiableTypeTarget.value
        this.technologiableId  = this.technologiableIdTarget.value

        console.log("step_technologiable_preview_load_controller: this.technologiableType")
        console.log(`step_technologiable_preview_load_controller: ${this.technologiableType}`)
        console.log("step_technologiable_preview_load_controller: this.technologiableId")
        console.log(`step_technologiable_preview_load_controller: ${this.technologiableId}`)
    }

    setLoadUrl(){
        console.log("step_technologiable_preview_load_controller: this.selectTypeValue")
        console.log(`step_technologiable_preview_load_controller: ${this.selectTypeValue}`)

        if (this.technologiableType == articleCase) {
            var url = `/article/articles/${this.technologiableId}/preview?preview_type=basic_preview`
        } else if (this.technologiableType == unitCase) {
            var url = `/unit/units/${this.technologiableId}/preview?type=${this.selectTypeValue}`
        } else if (this.technologiableType == algorithmCase) {
            var url = `/algorithm/algorithms/${this.technologiableId}/preview?preview_type=${this.selectTypeValue}`
        } else if (this.technologiableType == cheatSheetCase) {
            var url = `/cheat_sheet/cheat_sheets/${this.technologiableId}/preview?preview_type=${this.selectTypeValue}`
        } else if (this.technologiableType == cheatSheetGroupCase) {
            var url = `/cheat_sheet_group/cheat_sheet_groups/${this.technologiableId}/preview?preview_type=${this.selectTypeValue}`
        } else {
            console.log("Can not set load url, case not programmed")
        }
        return url;
    }

    // TODO: add load spinner
    loadPreview(){
        this.getTechnologiableParams()
        // DOC: Case when we dealing with new algorithm form and new step and technology not set to it yet
        if (!(this.technologiableType && this.technologiableId)) { return; }
        this.previewUrl = this.setLoadUrl()

        Rails.ajax({
            type: 'GET',
            url: this.previewUrl,
            dataType: 'json',
            success: (data) => {
                console.log("step_technologiable_preview_load_controller: Preview loaded!")
                this.preview = data.preview
                this.insertPreview(this.preview)
            },
            error: (response) => {
                console.log("step_technologiable_preview_load_controller: PReview not loaded! Something went wrong.")
                console.log(response)
                // this.toggleLoadSpinner("hide")
                // this.toggleRetryCard("show")
            }
        })
    }

    insertPreview(preview){
        this.previewContainerTarget.innerHTML = "";
        this.previewContainerTarget.insertAdjacentHTML('beforeend', preview)
    }

}