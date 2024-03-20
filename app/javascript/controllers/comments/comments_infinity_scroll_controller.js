import { Controller } from "@hotwired/stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {
    static values = {
        technologyUuid: String,
        technologyType: String,
        scenario: String
    }

    // static targets = [ "entries", "pagination" ]
    static targets = ["entries", "loadingIndicator", "contentArea", "loadMoreButton", "retryCard" ]

    connect() {
        console.log("comments_list_controller controller connected")
        let initialPageNumber = 1
        this.currentPage = initialPageNumber
        this.initialLoad()
    }

    disconnect() {
        console.log("comments_list_controller disconnected")
    }

    // PRIVATE

    toggleLoadSpinner(action){
        // var spinnerSelector = this.loadingIndicatorTarget
        // var currentActiveTabId = this.currentActiveTab.id

        let displayStyle = ""
        if (action == "show"){
            displayStyle = ""
        } else if (action == "hide") {
            displayStyle = 'none'
        }

        this.loadingIndicatorTarget.style.display = displayStyle
    }

    initialLoad() {
        this.initialLoadEntries()
    }

    initialLoadEntries() {
        this.toggleLoadSpinner("show")
        let url = this.prepareUrl()

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("comments_infinity_scroll_controller: Initial comments loaded!")
                console.log(data)
                this.toggleLoadSpinner("hide")
                this.insertEntries(data.entries)
                this.increasePageNumber()
                this.toggleLoadMoreButton("show")
            },
            error: (response) => {
                console.log("comments_infinity_scroll_controller: Initial comments not loaded!")
                console.log(response)
                this.toggleLoadSpinner("hide")
                this.toggleRetryCard("show")
            }
        })
    }

    prepareUrl(){
        console.log(this.technologyUuidValue)
        let technologyUuid = this.technologyUuidValue
        let technologyType = this.technologyTypeValue
        let scenario = this.scenarioValue
        let page = this.currentPage
        let params = `commentable_id=${technologyUuid}&commentable_type=${technologyType}&page=${page}&scenario=${scenario}`
        let url = `/comments/list?${params}`
        return url
    }

    toggleLoadMoreButton(action) {
        let displayStyle = ""
        if (action == "show"){
            displayStyle = ""
        } else if (action == "hide") {
            displayStyle = 'none'
        }

        this.loadMoreButtonTarget.style.display = displayStyle
    }

    insertEntries(entries) {
        this.contentAreaTarget.insertAdjacentHTML('beforeend', entries)
    }

    increasePageNumber() {
        this.currentPage = this.currentPage + 1
    }

    toggleRetryCard(action){
        if (action == "hide"){
            this.retryCardTarget.style.display = 'none'
        } else if (action == "show") {
            this.retryCardTarget.style.display = ''
        }
    }

    retryLoad(){
        this.toggleRetryCard("hide")
        if (this.currentPage == 1) {
            this.initialLoadEntries()
        } else {
            this.loadMore()
        }
    }

    loadMore() {
        this.toggleLoadSpinner("show")
        let url = this.prepareUrl()

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("comments_infinity_scroll_controller: Comments loaded!")
                console.log(data)
                this.toggleLoadSpinner("hide")
                this.insertEntries(data.entries)
                if (data.entries.length > 0) {
                    this.increasePageNumber()
                    this.toggleLoadMoreButton("show")
                } else {
                    // No more comments examples exists, do nothing
                    this.toggleLoadMoreButton("hide")
                }
            },
            error: (response) => {
                console.log("comments_infinity_scroll_controller: Comments not loaded!")
                console.log(response)
                this.toggleLoadSpinner("hide")
                this.toggleRetryCard("show")
            }
        })
    }
}