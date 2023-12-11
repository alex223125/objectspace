import { Controller } from "@hotwired/stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {
    static values = {
        technologyUuid: String,
        technologyType: String
    }

    // static targets = [ "entries", "pagination" ]
    static targets = ["entries", "loadingIndicator", "contentArea", "loadMoreButton", "retryCard" ]

    connect() {
        console.log("usage_examples_display_infinity_scroll_controller controller connected")
        let initialPageNumber = 1
        this.currentPage = initialPageNumber
        this.initialLoad()
    }

    disconnect() {
        console.log("usage_examples_display_infinity_scroll_controller disconnected")
    }

    // scroll() {
    //
    //     let nextPage = this.paginationTarget.querySelector("a[rel='next']")
    //
    //     if (nextPage == null) {
    //         return
    //     }
    //
    //     let url = nextPage.href
    //
    //     let body = document.body,
    //         html = document.documentElement
    //
    //     let height = Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight)
    //
    //     if (window.pageYOffset >= height - window.innerHeight - 100) {
    //         this.loadMore(url);
    //     }
    // }

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
                console.log("usage_examples_display_infinity_scroll_controller: Initial usage examples loaded!")
                console.log(data)
                this.toggleLoadSpinner("hide")
                this.insertEntries(data.entries)
                this.increasePageNumber()
                this.toggleLoadMoreButton("show")
            },
            error: (response) => {
                console.log("usage_examples_display_infinity_scroll_controller: Initial usage examples not loaded!")
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
        let page = this.currentPage
        let params = `technology_uuid=${technologyUuid}&technology_type=${technologyType}&page=${page}`
        let url = `/usage_examples/preview_index?${params}`
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
                console.log("usage_examples_display_infinity_scroll_controller: Usage examples loaded!")
                console.log(data)
                this.toggleLoadSpinner("hide")
                this.insertEntries(data.entries)
                if (data.entries.length > 0) {
                    this.increasePageNumber()
                    this.toggleLoadMoreButton("show")
                } else {
                    // No more usage examples exists, do nothing
                    this.toggleLoadMoreButton("hide")
                }
            },
            error: (response) => {
                console.log("usage_examples_display_infinity_scroll_controller: Usage examples not loaded!")
                console.log(response)
                this.toggleLoadSpinner("hide")
                this.toggleRetryCard("show")
            }
        })
    }
}