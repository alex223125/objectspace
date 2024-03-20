import { Controller } from "@hotwired/stimulus"

const improvementsTab = "improvements"

export default class extends Controller {

    static targets = ["pageArea"]

    connect() {
        console.log("unit_page_controller connected")
    }

    disconnect() {
        console.log("unit_page_controller disconnected")
    }

    initialize() {
        console.log("unit_page_controller initialized")
        var that = this
        // $(document).ready(function () {
        //     that.setTab()
        // });
        // $(document).on("turbo:render turbo:load", function() {
        //     that.setTab()
        // })
        $(window).on('load turbo:load', function() {
            that.setTab()
        });
    }

    // PRIVATE
    setTab(){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const targetTab = urlParams.get('target_tab')

        if (targetTab == improvementsTab) {
            var tab = this.pageAreaTarget.querySelector('#improvements-tab')
            $(tab).click()
        }
    }
}

// <div data-controller="wizard" data-action="turbo:load@document->unit_page#setTab>...</div>
