import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // static targets = ["query", "cocktails"]
    static targets = ["textQuery", "uuidQuery", "entries"]

    initialize() {
        let options = {
            rootMargin: '200px',
        }
        this.page = 1;
        this.lastTextQueryValue = ""
        this.lastUuidQueryValue = ""
    }

    connect() {
        console.log("Search controller connected")
    }

    submit() {
        console.log("Search submit fired!")
        const textQuery = this.textQueryTarget.value
        const uuidQuery = this.uuidQueryTarget.value

        // with each new query we make page to number 1 befor request
        if (textQuery == this.lastTextQueryValue && uuidQuery == this.lastUuidQueryValue) {
            // do nothing
        } else {
            this.page = 1
        }

        // let url = `/search/?query=${value}`
        let url = `/search`
        let postData = {query: textQuery, uuid: uuidQuery, page: this.page}
        Rails.ajax({
            type: 'POST',
            url: url,
            dataType: 'json',
            data: new URLSearchParams(postData).toString(),
            // data: {query: value, page: this.page},
            success: (data) => {
                console.log("Search submit success!")

                if (textQuery == this.lastTextQueryValue && uuidQuery == this.lastUuidQueryValue) {
                    // add results to the end
                    this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                } else {
                    // clear results
                    this.entriesTarget.innerHTML = "";
                    // add new result to the end
                    this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
                }

                this.page = this.page + 1
                this.totalPages = data.pagination.pages

                this.lastTextQueryValue = textQuery
                this.lastUuidQueryValue = uuidQuery

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

    clearEntries(){
        this.entriesTarget.innerHTML = "";
    }

    resetQueryInputs(){
        this.textQueryTarget.value = "";
        this.uuidQueryTarget.value = "";
    }


    // generate template for output
    // cocktailTemplate(item) {
    //     return `<div>
    // <h4>${item.name} <small>${item.glass}</small></h4>
    // <p>${item.preparation}</p>
    // </div> `
    // }

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