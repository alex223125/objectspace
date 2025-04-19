// TODO: rename to algorithm_node_type_select
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
        'frameworkMemberAdditionButton',
    ];


    connect() {
        console.log("framework_member_addition_controller connected")

    }

    disconnect() {
        console.log("framework_member_addition_controller disconnected")
    }


    // PUBLIC
    handleMemberAdditionButtonClick(){
        // 1) Open modal to select technology (algorithm or method)
        console.log("11111111111111111111111111111")
        console.log(this.frameworkMemberAdditionButtonTarget)
        this.frameworkMemberAdditionButtonTarget.click()
    }


}