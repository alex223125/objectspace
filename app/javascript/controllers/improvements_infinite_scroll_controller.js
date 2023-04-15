import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["entries", "pagination", "searchQuery",
                      // sorting options
                      "sortingOption", "openClosedOption"  ]

    initialize() {
        let options = {
            rootMargin: '200px',
        }

        this.unitVersionId = window.location.href.split("/").at(-1);
        this.page = 1;
        this.openClosedFilterState = 1;

        this.intersectionObserver = new IntersectionObserver(entries => this.processIntersectionEntries(entries), options)

        // $('input[name="helper-radio-by-update-time"]:checked').val();
    }

    connect() {
        console.log("improvements infinity scroll connected")
        this.intersectionObserver.observe(this.paginationTarget)
    }

    disconnect() {
        console.log("improvements infinity scroll disconnected")
        this.intersectionObserver.unobserve(this.paginationTarget)
    }

    processIntersectionEntries(entries) {
        console.log("processIntersectionEntries triggered")
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                this.loadMore()
            }
        })
    }

    submit(){
        console.log("Sumit button triggered")
        console.log("Query is:")
        console.log(this.searchQueryTarget.value)
    }

    selectSortingOption(){
        console.log("One of the sorting options is clicked")
    }

    selectOpenClosedOption(){
        // make all wite
        this.openClosedOptionTargets.forEach((el, i) => {
            el.classList.remove("bg-gray-100")
        })

        // highlight  selected
        this.openClosedOptionTargets.forEach((el, i) => {
            el.classList.toggle("bg-gray-100", event.target == el )
        })
        // this.inputTarget.value = event.target.innerText
        // this.submitTarget.disabled = false
    }

    loadMore() {
        console.log("load more triggered")
        console.log(this.page)
        if (this.totalPages == this.page) {
            console.log("All pages are displayed")
            return;
        }

        let url = `/improvements?unit_version_id=${this.unitVersionId}&page=${this.page}`
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                this.page = this.page + 1
                this.totalPages = data.pagination.pages
            }
        })
    }
}