import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    static targets = [
        'interfaceGroupsArea',
        'addActionOptionsModalOriginalButton',
        'deleteActionsGroupModalOriginalButton',
        'removeActionsOriginalButton'
    ];

    connect() {
        console.log("Management options button controller connected")
    }

    disconnect() {
        console.log("Management options button controller disconnected")
    }

    // PUBLIC
    handleAddNewActionButtonClick(){
        this.addActionOptionsModalOriginalButtonTarget.click()
    }

    handleDeleteActionsGroupButton(){
        this.deleteActionsGroupModalOriginalButtonTarget.click()
    }

    handleRemoveActionsButtonClick(){
        this.removeActionsOriginalButtonTarget.click()
    }

}