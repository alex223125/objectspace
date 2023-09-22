import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // static targets = ["query", "cocktails"]
    static targets = ["textQuery", "uuidQuery", "instructionType", "scenario", "entries"]

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
        console.log("Search controller connected")
    }

    disconnect() {
        console.log("Search controller disconnected")
    }



    // add methond load more
    // submit only for first tme uniq esarch
    // load more for loading more record in scope of pagination
    //
    // right now bug
    // when we 2 times seatch same term

    submit() {
        console.log("Search submit fired!")

        // 1.set request params
        const textQuery = this.textQueryTarget.value
        const uuidQuery = this.uuidQueryTarget.value
        const instructionType = this.instructionTypeTarget.value
        const scenario = this.scenarioTarget.value
        this.page = 1

        let url = `/search`
        let postData = {query: textQuery, uuid: uuidQuery,
                            page: this.page, type: instructionType, scenario: scenario}

        // 2.check if same form submitted second time
        if (textQuery == this.lastTextQueryValue &&
            uuidQuery == this.lastUuidQueryValue &&
            instructionType == this.lastInstructionType ) {

            console.log("Same search request detected")
            return;
        }


        // 3.clear past results
        this.clearEntries



        // // with each new query we make page to number 1 befor request
        // if (textQuery == this.lastTextQueryValue && uuidQuery == this.lastUuidQueryValue) {
        //     // do nothing
        // } else {
        //     this.page = 1
        // }

        // let url = `/search/?query=${value}`

        // 3.make request
        Rails.ajax({
            type: 'POST',
            url: url,
            dataType: 'json',
            data: new URLSearchParams(postData).toString(),
            // data: {query: value, page: this.page},
            success: (data) => {
                console.log("Search submit success!")

                // 4.1 place results in dom
                this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)

                // if (textQuery == this.lastTextQueryValue && uuidQuery == this.lastUuidQueryValue) {
                //     // add results to the end
                //     this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                // } else {
                //     // clear results
                //     this.entriesTarget.innerHTML = "";
                //     // add new result to the end
                //     this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                // }

                // this.page = this.page + 1
                this.totalPages = data.pagination.pages

                // 4.2 save history data
                this.lastTextQueryValue = textQuery
                this.lastUuidQueryValue = uuidQuery
                this.lastInstructionType = instructionType






                // // create template for each item
                // var cocktailHTML = "";
                // var cocktailArray = Object.values(data)[0]
                // cocktailArray.forEach(cocktail => {
                //     cocktailHTML += this.cocktailTemplate(cocktail)
                // });
                //
                // // assign results to list output
                // this.itemsTarget.innerHTML = cocktailHTML;
            }
        })

    }

    loadMore(){
        // 1.set request params
        this.page = this.page + 1
        if (this.page > this.totalPages) {
            return;
        }

        const textQuery = this.textQueryTarget.value
        const uuidQuery = this.uuidQueryTarget.value
        const instructionType = this.instructionTypeTarget.value

    }


    resetForm(){
        console.log("resetForm triggered")
        this.resetQueryInputs()
        this.clearEntries()
        this.clearHistory()
    }


    // PRIVATE

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