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
        console.log("improvements_infinite_scroll connected");

        // 1. SAFE WORKSPACE TARGET GUARD MAPPING
        if (this.hasPaginationTarget) {
            this.intersectionObserver.observe(this.paginationTarget);
        } else {
            console.warn("Telemetry warning: 'pagination' target node not found in current DOM fragment.");
        }

        // ====================================================================
        // AUTOMATED BOOTSTRAP INITIAL LOAD TRIGGER
        // ====================================================================
        // If we are on page 1 and no requests have run yet, force an immediate
        // network fetch to pre-populate the high-density grid rows.
        if (this.currentPage === 1) {
            console.log("Launching automated initial data stream fetch pass...");

            // Re-use your search values extraction safely to query baseline data blocks
            var searchQuery = this.hasSearchQueryTarget ? this.searchQueryTarget.value : "";
            var statusFilter = this.statusFilter;
            var sortingOption = this.sortingOption;
            var techVersionOption = this.techVersionOption;

            this.load(searchQuery, statusFilter, sortingOption, techVersionOption);
        }
    }

    disconnect() {
        console.log("improvements_infinite_scroll disconnected")

        // Safely unobserve only if the target reference was successfully registered
        if (this.hasPaginationTarget) {
            this.intersectionObserver.unobserve(this.paginationTarget)
        }
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
    // Inside your improvements_infinite_scroll_controller.js
    processIntersectionEntries(entries) {
        console.log("processIntersectionEntries triggered")
        entries.forEach(entry => {
            // Only fire the infinite load sequence if the element is intersecting
            // AND the essential searchQuery element target has loaded into view boundaries
            if (entry.isIntersecting && this.hasSearchQueryTarget) {
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
        console.log("improvements_infinite_scroll_controller: load triggered");

        let improvementsSearchParams = {
            "improvements_search": {
                "tech_id": this.technologyId,
                "tech_type": this.technologyType,
                "page": this.currentPage, // Pass page 1 natively
                "query": searchQuery,
                "status": statusFilter,
                "sort_by": sortingOption,
                "tech_version": techVersionOption
            }
        };

        let params = $.param(improvementsSearchParams);
        let url = `/api/improvements?${params}`;

        console.log("improvements_infinite_scroll_controller: before Rails.ajax");
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Initial load chunk response successfully received:", data);

                // Safe guard fallback: Clear out any baseline loading placeholders inside your container list
                if (this.hasEntriesTarget) {
                    const placeholder = this.entriesTarget.querySelector(".animate-pulse, .border-dashed");
                    if (placeholder || this.currentPage === 1) {
                        this.entriesTarget.innerHTML = "";
                    }
                }

                // Append the compiled partial HTML card string into the display feed container
                if (data.entries && data.entries.trim().length > 0) {
                    this.entriesTarget.insertAdjacentHTML('beforeend', data.entries);
                } else {
                    this.entriesTarget.innerHTML = `
                        <div class="p-6 text-center border border-dashed border-slate-800 rounded-xl bg-slate-900/10 text-xs font-mono text-slate-500 uppercase tracking-widest">
                          [ NO_ACTIVE_LOG_SEQUENCES_FOUND_IN_BUFFER_CACHE ]
                        </div>`;
                }

                // Increment page indicators smoothly to page 2 to let subsequent scrolling take over
                this.currentPage = this.currentPage + 1;
                this.totalPages = data.pagination ? data.pagination.pages : 1;
            },
            error: (err) => {
                console.error("Initial load pipeline error:", err);
            }
        });
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

        if (this.totalPages > 0 && this.currentPage > this.totalPages) {
            console.log("All pages are displayed")
            return;
        }

        // 1. SAFE WORKSPACE GUARD MATRIX: Extract the clean search input string natively
        var searchQuery = this.hasSearchQueryTarget ? this.searchQueryTarget.value : ""

        var statusFilter = this.statusFilter
        var sortingOption = this.sortingOption
        var techVersionOption = this.techVersionOption

        let improvementsSearchParams = {
            "improvements_search": {
                "tech_id": this.technologyId,
                "tech_type": this.technologyType,
                "page": this.currentPage,
                "query": searchQuery, // <-- FIX: Passes clean, native text strings or empty "" fields
                "status": statusFilter,
                "sort_by": sortingOption,
                "tech_version": techVersionOption
            }
        }

        let params = $.param(improvementsSearchParams)
        let url = `/improvements?${params}`

        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Data packet received from endpoint matrix:", data)

                // 2. DOM POPULATION AND RESET LOGIC
                if (data.entries && data.entries.trim().length > 0) {
                    // Wipe the baseline initial placeholder string when the first data packet lands safely
                    if (this.currentPage === 1 && this.hasEntriesTarget) {
                        this.entriesTarget.innerHTML = ""
                    }
                    this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                } else if (this.currentPage === 1 && this.hasEntriesTarget) {
                    // Output a premium empty alert pane if zero records exist matching current query filters
                    this.entriesTarget.innerHTML = `
                        <div class="p-6 text-center border border-dashed border-slate-800 rounded-xl bg-slate-900/10 text-xs font-mono text-slate-500 uppercase tracking-widest">
                          [ NO_ACTIVE_LOG_SEQUENCES_FOUND_IN_BUFFER_CACHE ]
                        </div>`
                }

                this.currentPage = this.currentPage + 1
                this.totalPages = data.pagination ? data.pagination.pages : 1
            },
            error: (error) => {
                console.error("Telemetry AJAX pipeline exception trace:", error)
            }
        })
    }
}