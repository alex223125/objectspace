import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['input']

    initialize(){
        this.searchQuery = ""
    }

    connect() {
        console.log("Navigation search from controller connected")
    }


    disconnect() {
        console.log("Navigation search from controller disconnected")
    }

    // PUBLIC
    submit(){
        this.getParameters()
        this.redirect()
    }

    // PRIVATE
    getParameters(){
        this.searchQuery = this.inputTarget.value
    }

    redirect(){
        var origin = window.location.origin
        location.href = `${origin}/technologies?search_query=${this.searchQuery}`
    }

}