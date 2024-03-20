import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['replyForm']

    initialize() {
        console.log("comment_reply_controller initialized")
    }

    connect() {
        console.log("comment_reply_controller connected")
    }

    disconnect() {
        console.log("comment_reply_controller disconnected")
    }

    // PUBLIC
    toggleReplyForm(){
        if (this.replyFormTarget.style.display == 'none') {
            this.replyFormTarget.style.display = ''
        } else {
            this.replyFormTarget.style.display = 'none'
        }
    }
}