import { Controller } from "@hotwired/stimulus"

const defaultPage = 1
const defaultStatusFilter = "view_all"
const defaultSortingOption = "newest"
const defaultTechVersionOption = "all"

export default class extends Controller {
    static targets = ["entries", "searchQuery",
                      // sorting options
                      "sortingOption", "openClosedOption",
                      "pagination"  ]

    initialize() {
        console.log("improvements_infinite_scroll initialized")
        let options = {
            rootMargin: '200px'
        }

        this.technologyId = window.location.pathname.split("/").at(-1);
        this.technologyType = window.location.pathname.split("/").at(-2);

        this.currentPage = defaultPage
        this.statusFilter = defaultStatusFilter
        this.sortingOption = defaultSortingOption
        this.techVersionOption = defaultTechVersionOption

        this.intersectionObserver = new IntersectionObserver(entries => this.processIntersectionEntries(entries), options)

        // $('input[name="helper-radio-by-update-time"]:checked').val();
    }

    connect() {
        console.log("improvements_infinite_scroll connected")
        this.intersectionObserver.observe(this.paginationTarget)
    }

    disconnect() {
        console.log("improvements_infinite_scroll disconnected")
        this.intersectionObserver.unobserve(this.paginationTarget)
    }

    submit(){
        console.log("Sumit button triggered")
        var searchQuery = this.searchQueryTarget.value
        var statusFilter = this.statusFilter
        var sortingOption = this.sortingOption
        var techVersionOption = this.techVersionOption
        this.load(searchQuery, statusFilter, sortingOption, techVersionOption)
    }

    selectTechVersionOption(event) {
        var clickedButton = event.target
        this.setTechVersion(clickedButton)
    }

    selectSortingOption(event){
        var selectedOption = event.target
        this.setSortingOption(selectedOption)
    }

    selectOpenClosedOption(event){
        var clickedButton = event.target
        // make all white
        this.openClosedOptionTargets.forEach((el, i) => {
            el.classList.remove("bg-gray-100")
        })
        // highlight  selected
        this.openClosedOptionTargets.forEach((el, i) => {
            el.classList.toggle("bg-gray-100", clickedButton == el )
        })
        // set filter
        this.setStatusFilter(clickedButton)
    }

    // PRIVATE
    processIntersectionEntries(entries) {
        console.log("processIntersectionEntries triggered")
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                this.loadMore()
            }
        })
    }

    setSortingOption(option) {
        this.sortingOption = option.dataset.sortingOptionValue
    }

    setStatusFilter(clickedButton){
        this.statusFilter = clickedButton.dataset.statusFilterValue
    }


    setTechVersion(clickedButton){
        this.techVersionOption = clickedButton.dataset.filterOptionValue
    }

    load(searchQuery, statusFilter, sortingOption, techVersionOption) {
        console.log("improvements_infinite_scroll_controller: load triggered")

        let improvementsSearchParams = {
            "improvements_search": {
                "tech_id": this.technologyId,
                "tech_type": this.technologyType,
                "page": this.currentPage,
                "query": searchQuery,
                "status": statusFilter,
                "sort_by": sortingOption,
                "tech_version": techVersionOption
            }
        }
        let params = $.param(improvementsSearchParams)
        // let params = `improvements_search%5Btech_id=${this.technologyId}&tech_type=${this.technologyType}
        // &page=${this.currentPage}&query=${searchQuery}&status=${statusFilter}&sort_by=${sortingOption}&tech_version=${techVersionOption}`
        let url = `/improvements?${params}`

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                this.currentPage = this.currentPage + 1
                this.totalPages = data.pagination.pages
                // this.setLastSearchData(searchQuery, statusFilter, sortingOption, techVersionOption)
            }
        })
    }



    // setLastSearchData() {
    //     this.lastSearch = {
    //         tech_id: this.technologyId,
    //         tech_type: this.technologyType,
    //         query: searchQuery,
    //         status: statusFilter,
    //         sort_by: sortingOption,
    //         tech_version: techVersionOption
    //     }
    // }

    // TODO: Add load indicator duringr reuqest
    // TODO: add retry request in case of ajax failure
    loadMore() {
        console.log("improvements_infinite_scroll_controller: load more triggered")
        console.log(this.currentPage)
        if (this.totalPages == this.currentPage) {
            console.log("All pages are displayed")
            return;
        }

        let url = `/improvements?unit_version_id=${this.unitVersionId}&page=${this.currentPage}`
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                this.currentPage = this.currentPage + 1
                this.totalPages = data.pagination.pages
            }
        })
    }
}