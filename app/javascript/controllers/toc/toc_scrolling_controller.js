import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    connect() {
        console.log("Toc scrolling controller connected")
    }

    disconnect() {
        console.log("Toc scrolling controller disconnected")
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

        // location.hash = '#algorithm-description-61'
        // let element = $('#algorithm-description-61')
        // $(document.body).scrollTop(element.offset().top);
        // $(document).scrollTop();
        // $("html, body").animate({ scrollTop: 0 }, 2000);
    }

}