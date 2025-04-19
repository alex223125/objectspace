// TODO: rename to algorithm_node_type_select
import { Controller } from '@hotwired/stimulus';
import { Modal } from 'flowbite';


// 'bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-40 aaaa',

// options with default values
const options = {
    placement: 'bottom-right',
    backdrop: 'dynamic',
    backdropClasses:
        'bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-10 bbbb',
    closable: true,
    onHide: () => {
        console.log('modal is hidden');
    },
    onShow: () => {
        console.log('modal is shown');
    },
    onToggle: () => {
        console.log('modal has been toggled');
    },
};

// instance options object
const instanceOptions = {
    id: 'modalEl',
    override: true
};


export default class extends Controller {
    static targets = [
        'modalArea',
        'modalBody',
        'modalButton'
    ];


    connect() {
        // set the modal menu element
        const targetEl = this.modalBodyTarget
        console.log("delete_framework_member_modal_controller connected")

         /*
         * $targetEl: required
         * options: optional
         */
        this.modal = new Modal(targetEl, options, instanceOptions);

    }

    disconnect() {
        console.log("delete_framework_member_modal_controller disconnected")
    }


    // PUBLIC
    openModal(){
        this.modal.show();
    }

    closeModal(){
        this.modal.hide();
    }

    // handleMemberAdditionButtonClick(){
    //     // 1) Open modal to select technology (algorithm or method)
    //     console.log("11111111111111111111111111111")
    //     console.log(this.frameworkMemberAdditionButtonTarget)
    //     this.frameworkMemberAdditionButtonTarget.click()
    // }


}
