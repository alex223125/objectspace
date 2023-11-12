import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import {useMutation} from "stimulus-use";

// const nestedFieldsTemplateSelector = ".nested-fields-interface-members"
const nestedFieldsTemplateSelector = ".nested-fields-interface-group-actions"


export default class extends Controller {

    static targets = [
        'interfaceMembersArea',
        'memberPositionVisibleField',
        'memberPositionHiddenField'
    ];

    connect() {
        console.log("Interface members drag controller connected")
        this.sortable = Sortable.create(this.element, {
            group: 'interfaceMebmers',
            animation: 150,
            onEnd: this.end.bind(this)
            // filter: ".nodraggablesteps"
        })

        // mutation observer to recalculate indexes when new step is added
        this.membersAmount = this.currentMembersAmount()
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})

        this.handleFormWithPredefinedMembers()
    }

    disconnect() {
        console.log("Interface members drag controller disconnected")
    }

    mutate(entries) {

        var membersAmountAfterMutation = this.currentMembersAmount()
        var change = this.membersAmount - membersAmountAfterMutation

        if (change == 1)  {
            var typeOfChange = 'memberRemoved'
        } else if (change == -1) {
            var typeOfChange = 'memberAdded'
        }

        if (typeOfChange == 'memberAdded') {
            // new group added
            this.recalculateIndexes()
            this.membersAmount = this.membersAmount + 1
        } else if (typeOfChange == 'memberRemoved') {
            // group been removed
            this.recalculateIndexes()
            this.membersAmount = this.membersAmount - 1
        }
    }


    // PRIVATE

    handleFormWithPredefinedMembers(){
        if (this.memberPositionHiddenFieldTargets.length >= 1 ) {
            this.recalculateIndexes()
        }
    }

    currentMembersAmount(){
        return this.memberPositionHiddenFieldTargets.length
    }


    end(event) {
        this.recalculateIndexes()
    }

    recalculateIndexes(){
        // // recount hidden inputs indexes

        // 1.select only hidden (hidden steps are deleted steps which was taken from db to edit form and then deleted in form)
        let filteredHiddenFieldTargets = this.memberPositionHiddenFieldTargets.filter((field) => {
            return field.closest(nestedFieldsTemplateSelector).style.display != 'none'
        });

        // 2.update indexes
        // var positionHiddenElemenets = [...this.interfaceGroupsAreaTarget.querySelectorAll(".interface-group-position-hidden-field")]
        var positionHiddenElemenets = [...filteredHiddenFieldTargets]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.value = (index + 1)
        });


        // 1.select only visible (hidden steps are deleted steps which was taken from db to edit form and then deleted in form)
        let filteredVisibleFieldTargets = this.memberPositionVisibleFieldTargets.filter((field) => {
            return field.closest(nestedFieldsTemplateSelector).style.display != 'none'
        });

        // var positionHiddenElemenets = [...this.stepsAreaTarget.querySelectorAll(".step-position-visible-field")]
        // var positionHiddenElemenets = [...this.interfaceGroupsAreaTarget.querySelectorAll(".interface-group-position-visible-field")]
        var positionVisibleElemenets = [...filteredVisibleFieldTargets]
        positionVisibleElemenets.forEach(function callback(value, index) {
            value.innerHTML = (index + 1)
            // value.text(index + 1)
        });


    }

}
