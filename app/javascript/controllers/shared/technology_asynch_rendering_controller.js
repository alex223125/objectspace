// responsibility zone: load asynch-y articles, methods, algorithms on ui when we open specific accordion or pick attachment during algorithm reading
// responsibility zone - addition of actins in differen places around simple clasees, container groups etc
import { Controller } from '@hotwired/stimulus';
import { initFlowbite } from "flowbite";

const articleCase = "Articles::Article"
const unitCase = "Units::Unit"
const algorithmCase = "Algorithms::Algorithm"
const cheatSheetCase = "CheatSheets::CheatSheet"
const cheatSheetGroupCase = "CheatSheetGroups::CheatSheetGroup"

export default class extends Controller {

    static values = {
        technologiableType: String,
        technologiableId: String
    }

    static targets = [
        'container',
        'loadingIndicator',
        'retryCard'
    ]

    initialize() {
        console.log("technology asynch rendering controller initialized")
    }

    connect() {
        console.log("technology asynch rendering controller connected")
        this.technologiableType = this.technologiableTypeValue
        this.technologiableId = this.technologiableIdValue
        this.loadView()
    }

    disconnect() {
        console.log("technology asynch rendering controller disconnected")
    }

    // PUBLIC
    retryLoad(){
        this.toggleRetryCard("hide")
        this.loadView()
    }


    // PRIVATE
    loadView(){
        // set params
        // this.toggleClass = this.data.get('technologiableType')
        // let technologiableType =  event.target.dataset.technologiableType
        // let technologiableId = event.target.dataset.technologiableId


        var url = this.setLoadUrl()

        // 1.set load animation
        this.toggleLoadingIndicator("show")

        // 2 make request
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("technology asynch rendering controller: View loaded!")
                // console.log(data.preview)
                // 3.disable load animation
                this.toggleLoadingIndicator("hide")
                this.insertView(data)
                this.recalculateViewAccordionsSize()
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            },
            error: (response) => {
                console.log("technology asynch rendering controller: View not loaded!")
                console.log(response)
                this.toggleLoadingIndicator("hide")
                this.toggleRetryCard("show")
            }

        })
    }

    recalculateViewAccordionsSize(){
        // we need it for node_accordion_controller to be sure that after
        // last load and display of algorithm step divs doesnt split with each other
        const trigger = new CustomEvent("recalculate-height");
        window.dispatchEvent(trigger);
    }

    setLoadUrl(){
        // 4.2 stet variables for substep inputs field
        var params = "type=regular"
        if (this.technologiableType == articleCase) {
            var url = `/article/articles/${this.technologiableId}/view?${params}`
        } else if (this.technologiableType == unitCase) {
            var url = `/unit/units/${this.technologiableId}/view?${params}`
        } else if (this.technologiableType == algorithmCase) {
            var url = `/algorithm/algorithms/${this.technologiableId}/view?${params}`
        } else if (this.technologiableType == cheatSheetCase) {
            var url = `/cheat_sheet/cheat_sheets/${this.technologiableId}/view?${params}`
        } else if (this.technologiableType == cheatSheetGroupCase) {
            var url = `/cheat_sheet_group/cheat_sheet_groups/${this.technologiableId}/view?${params}`
        } else {
            console.log("technology asynch rendering controller: Can not set load url, case not programmed")
        }
        return url;
    }

    insertView(data){
        this.containerTarget.innerHTML = "";
        this.containerTarget.insertAdjacentHTML('beforeend', data.view)

        // DOC: Some of the javascript doesnt work
        // after creation of new algorithm and when we redirected on show page
        // this workaround should initialize flowbite when we getting redirect
        // and dropdowns should work
        initFlowbite();
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