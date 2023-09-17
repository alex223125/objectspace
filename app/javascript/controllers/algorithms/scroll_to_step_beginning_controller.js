import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    connect() {
        console.log("Scroll to step beginning controller connected")
    }

    disconnect() {
        console.log("Scroll to step beginning controller disconnected")
    }


    // PUBLIC
    scroll(event){
        let anchor = event.target.dataset.anchor
        let element = $(`${anchor}`)
        console.log("Scroll to element:")
        console.log(element)

        $("html, body").animate({
            'scrollTop':   element.offset().top
        }, 1000);
    }

}