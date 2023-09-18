import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['container']
    static values = {
        backdropColor: { type: String, default: 'rgba(0, 0, 0, 0.8)' },
        restoreScroll: { type: Boolean, default: true }
    }

    connect() {
        console.log("technology_pick_modal_controller connected")
        // The class we should toggle on the container
        this.toggleClass = this.data.get('class') || 'hidden';

        // The ID of the background to hide/remove
        this.backgroundId = this.data.get('backgroundId') || 'modal-background';

        // The HTML for the background element
        this.backgroundHtml = this.data.get('backgroundHtml') || this._backgroundHTML();

        // Let the user close the modal by clicking on the background
        this.allowBackgroundClose = (this.data.get('allowBackgroundClose') || 'true') === 'true';

        // Prevent the default action of the clicked element (following a link for example) when opening the modal
        this.preventDefaultActionOpening = (this.data.get('preventDefaultActionOpening') || 'true') === 'true';

        // Prevent the default action of the clicked element (following a link for example) when closing the modal
        this.preventDefaultActionClosing = (this.data.get('preventDefaultActionClosing') || 'true') === 'true';
    }

    disconnect() {
        console.log("technology_pick_modal_controller disconnected")
        this.close();
    }

    // PUBLIC
    submit(){
        // 1.pick parent controller
        let selector = '#remote-technologies-pick-container'
        let controllerInstance = document.querySelector(selector).remote_technologies_pick
        // 2.pass submit selected items command
        controllerInstance.sumbitSeletedItems()
        // 3.close modal
        this.close()
    }


    open(e) {
        if (this.preventDefaultActionOpening) {
            e.preventDefault();
        }

        if (e.target.blur) {
            e.target.blur();
        }

        // Lock the scroll and save current scroll position
        // this.lockScroll();

        // Unhide the modal
        this.containerTarget.classList.remove(this.toggleClass);

        // Insert the background
        if (!this.data.get("disable-backdrop")) {
            document.body.insertAdjacentHTML('beforeend', this.backgroundHtml);
            this.background = document.querySelector(`#${this.backgroundId}`);
        }
    }

    close(e) {
        if (e && this.preventDefaultActionClosing) {
            e.preventDefault();
        }

        // Unlock the scroll and restore previous scroll position
        // this.unlockScroll();

        // Hide the modal
        this.containerTarget.classList.add(this.toggleClass);

        // Remove the background
        if (this.background) { this.background.remove() }
    }

    // PRIVATE
    closeBackground(e) {
        if (this.allowBackgroundClose && e.target === this.containerTarget) {
            this.close(e);
        }
    }

    closeWithKeyboard(e) {
        if (e.keyCode === 27 && !this.containerTarget.classList.contains(this.toggleClass)) {
            this.close(e);
        }
    }

    _backgroundHTML() {
        return `<div id="${this.backgroundId}" class="fixed top-0 left-0 w-full h-full" style="background-color: ${this.backdropColorValue}; z-index: 9998;"></div>`;
    }

    saveScrollPosition() {
        this.scrollPosition = window.pageYOffset || document.body.scrollTop;
    }

    restoreScrollPosition() {
        if (this.scrollPosition === undefined) return;

        document.documentElement.scrollTop = this.scrollPosition;
    }
}