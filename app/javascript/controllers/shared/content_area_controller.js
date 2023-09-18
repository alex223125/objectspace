// responsibility - get scope of the page where we have article, method, algorithm
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {


    static targets = [
        'area',
        'uuidInput'
    ]

    initialize() {
        console.log("content_area controller initialized")
    }

    connect() {
        console.log("content_area controller connected")
        this.element.controller = this;
    }

    disconnect() {
        console.log("content_areacontroller disconnected")
    }


}