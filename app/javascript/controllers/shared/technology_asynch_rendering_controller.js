// responsibility zone: load asynch-y articles, methods, algorithms on ui when we open specific accordion or pick attachment during algorithm reading
// responsibility zone - addition of actins in differen places around simple clasees, container groups etc
import { Controller } from '@hotwired/stimulus';

const unitCase = "Units::Unit"
const algorithmCase = "Algorithms::Algorithm"

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
        if (this.technologiableType == unitCase) {
            var url = `/unit/units/${this.technologiableId}/view`
        } else if (this.technologiableType == algorithmCase) {
            var url = `/algorithm/algorithms/${this.technologiableId}/view`
        } else {
            console.log("Can not set load url, case not programmed")
        }
        return url;
    }

    insertView(data){
        this.containerTarget.innerHTML = "";
        this.containerTarget.insertAdjacentHTML('beforeend', data.view)
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