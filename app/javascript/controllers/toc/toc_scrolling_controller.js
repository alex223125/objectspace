import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    static values = {
        type: String
    }

    connect() {
        console.log("Toc scrolling controller connected")
    }

    disconnect() {
        console.log("Toc scrolling controller disconnected")
    }


    // PUBLIC
    scroll(event){
        const anchor = event.target.dataset.anchor
        const element = $(`${anchor}`)
        console.log("Scroll to element:")
        console.log(element)

        if (this.typeValue == "toc_for_regular_page") {
            console.log("Regular page scroll option used")
            $("html, body").animate({
                'scrollTop':   element.offset().top
            }, 1000);
        } else if (this.typeValue == "toc_for_modal") {
            console.log("Modal scroll option used")
            element[0].scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
        } else {
            // toc type not defined case
            console.log("Regular page scroll option used")
            $("html, body").animate({
                'scrollTop':   element.offset().top
            }, 1000);
        }
        // location.hash = '#algorithm-description-61'
        // let element = $('#algorithm-description-61')
        // $(document.body).scrollTop(element.offset().top);
        // $(document).scrollTop();
        // $("html, body").animate({ scrollTop: 0 }, 2000);
    }

}