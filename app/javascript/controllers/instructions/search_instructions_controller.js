import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // static targets = ["query", "cocktails"]
    static targets = ["textQuery", "uuidQuery", "instructionType", "scenario", "entries", "loadMoreButton"]

    initialize() {
        let options = {
            rootMargin: '200px',
        }
        this.page = 1;
        this.lastTextQueryValue = ""
        this.lastUuidQueryValue = ""
        this.lastInstructionType = ""
    }

    connect() {
        console.log("search_instructions_controller: Search controller connected")
    }

    disconnect() {
        console.log("search_instructions_controller: Search controller disconnected")
    }


    // PUBLIC

    // right now bug
    // when we 2 times seatch same term

    submit() {
        console.log("search_instructions_controller: Search submit fired!")

        // 1.set request params
        const textQuery = this.textQueryTarget.value
        const uuidQuery = this.uuidQueryTarget.value
        const instructionType = this.instructionTypeTarget.value
        const scenario = this.scenario()

        console.log("search_instructions_controller: SCENARIO:")
        console.log(scenario)

        this.page = 1

        let url = `/search`
        let postData = {query: textQuery, uuid: uuidQuery,
                            page: this.page, type: instructionType, scenario: scenario}

        // 2.check if same form submitted second time
        if (textQuery == this.lastTextQueryValue &&
            uuidQuery == this.lastUuidQueryValue &&
            instructionType == this.lastInstructionType ) {

            console.log("search_instructions_controller: Same search request detected")
            return;
        }

        // 3.clear past results
        this.clearEntries()

        // 3.make request
        Rails.ajax({
            type: 'POST',
            url: url,
            dataType: 'json',
            data: new URLSearchParams(postData).toString(),
            // data: {query: value, page: this.page},
            success: (data) => {
                console.log("search_instructions_controller: Search submit success!")

                // 4.1 place results in dom
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)

                // 4.2 save history data
                this.lastTextQueryValue = textQuery
                this.lastUuidQueryValue = uuidQuery
                this.lastInstructionType = instructionType

                console.log("pagination")
                console.log(data.pagination)
                this.totalPages = data.pagination.pages
                if (this.totalPages > 1) {
                    console.log("search_instructions_controller: more then 1 page case")
                    this.toggleLoadMoreButton()
                }

            }
        })

    }

    loadMore(){
        console.log("search_instructions_controller: LoadMore fired!")
        // 1.set request params
        this.page = this.page + 1
        if (this.page > this.totalPages) {
            return;
        }

        const textQuery = this.textQueryTarget.value
        const uuidQuery = this.uuidQueryTarget.value
        const instructionType = this.instructionTypeTarget.value

        const scenario = this.scenario()
        console.log("search_instructions_controller: SCENARIO:")
        console.log(scenario)

        let url = `/search`
        let postData = {query: textQuery, uuid: uuidQuery,
            page: this.page, type: instructionType, scenario: scenario}


        // 2.make request
        Rails.ajax({
            type: 'POST',
            url: url,
            dataType: 'json',
            data: new URLSearchParams(postData).toString(),
            // data: {query: value, page: this.page},
            success: (data) => {
                console.log("search_instructions_controller: Search submit success!")

                // 4.1 place results in dom
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)

                // 4.2 save history data
                this.lastTextQueryValue = textQuery
                this.lastUuidQueryValue = uuidQuery
                this.lastInstructionType = instructionType

                this.totalPages = data.pagination.pages
                if (this.page == this.totalPages) {
                    this.toggleLoadMoreButton()
                }

            }
        })

    }


    resetForm(){
        console.log("search_instructions_controller: resetForm triggered")
        this.resetQueryInputs()
        this.clearEntries()
        this.clearHistory()
        this.hideLoadMoreButton()
    }


    // PRIVATE


    scenario() {
        if (this.hasScenarioTarget) {
            return this.scenarioTarget.value
        } else {
            return "search_instructions_controller: scenario_not_defined"
        }
    }

    clearEntries(){
        this.entriesTarget.innerHTML = "";
    }

    resetQueryInputs(){
        this.textQueryTarget.value = "";
        this.uuidQueryTarget.value = "";
    }

    clearHistory(){
        this.lastTextQueryValue = ""
        this.lastUuidQueryValue = ""
        this.lastInstructionType = ""
    }

    hideLoadMoreButton(){
        if (this.loadMoreButtonTarget.classList.contains("hidden")){
            // do nothing
        } else {
            this.loadMoreButtonTarget.classList.add("hidden")
        }
    }

    toggleLoadMoreButton(){
        if (this.loadMoreButtonTarget.classList.contains("hidden")){
            this.loadMoreButtonTarget.classList.remove("hidden")
        } else {
            this.loadMoreButtonTarget.classList.add("hidden")
        }
    }

}

// var of submit query 1

// fetch(`/search/?query=${value}`, {
//     headers: { accept: 'application/json'}
// }).then((response) => response.json())
//     .then(data => {
//         var cocktailHTML = "";
//
//         // create template for each item
//         var cocktailArray = Object.values(data)[0]
//         cocktailArray.forEach(cocktail => {
//             cocktailHTML += this.cocktailTemplate(cocktail)
//         });
//
//         // assign results to list output
//         this.itemsTarget.innerHTML = cocktailHTML;
//     });


// var of sumbit query 2

// Rails.ajax({
//     type: 'POST',
//     url: url,
//     dataType: 'json',
//     // headers: {
//     //     "Content-Type": "application/json",
//     //     "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
//     // },
//     headers: {
//         "Content-Type": "application/json",
//         "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
//     },
//     data: new URLSearchParams({query: value}).toString(),
//     success: (data) => {
//
//         console.log("Search submit success!")
//         var cocktailHTML = "";
//
//         // create template for each item
//         var cocktailArray = Object.values(data)[0]
//         cocktailArray.forEach(cocktail => {
//             cocktailHTML += this.cocktailTemplate(cocktail)
//         });
//
//         // assign results to list output
//         this.itemsTarget.innerHTML = cocktailHTML;
//     }
// })
