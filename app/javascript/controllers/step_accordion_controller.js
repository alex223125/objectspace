import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ['item'];


    connect() {
        console.log("step accordion connected")
        this.recalculateIndexes()
    }

    disconnect() {
        this.recalculateIndexes()
        console.log("step accordion disconnected")
    }

    recalculateIndexes(){
        // recount indexes
        var positionHiddenElemenets = $(".position-hidden-field")

        positionHiddenElemenets.each(function( index ) {
            $( this )[0].value = index + 1
        });

        // recount indexes 2
        var positionHiddenElemenets = $(".position-visible-field")
        positionHiddenElemenets.each(function( index ) {
            $( this ).text(index + 1)
        });
    }

    toggle({ target }) {
        const isOpening = target.hasAttribute('open');


        // class when open
        var classWhenOpen = "flex items-center justify-between w-full p-5 font-medium text-left border border-b-0 border-gray-200 rounded-t-xl focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-800 bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white"

        // class when closed
        var classWhenClosed = "flex items-center justify-between w-full p-5 font-medium text-left border border-gray-200 rounded-xl focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-500 dark:text-gray-400"

        console.log("Targetttttt")
        console.log(target.firstElementChild)

        // if (isOpening) {
        //     // if opening - close the others
        //     this.itemTargets.forEach((item) => {
        //         if (item === target) return;
        //         item.removeAttribute('open');
        //     });
        // }

        if (isOpening) {
            target.firstElementChild.className = classWhenOpen;
        } else {
            target.firstElementChild.className = classWhenClosed;
        }


    }
}