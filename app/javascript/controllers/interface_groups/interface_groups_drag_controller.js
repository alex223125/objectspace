import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import {useMutation} from "stimulus-use";

const nestedFieldsTemplateSelector = ".interface-group-nested-fields"

export default class extends Controller {

    static targets = [
        'interfaceGroupsArea',
        'groupPositionVisibleField',
        'groupPositionHiddenField'
    ];A

    connect() {
        console.log("Interface groups drag controller connected")
        this.sortable = Sortable.create(this.element, {
            group: 'interfaceGroup',
            animation: 150,
            onEnd: this.end.bind(this)
            // filter: ".nodraggablesteps"
        })

        // mutation observer to recalculate indexes when new step is added
        this.groupsAmount = this.currentGroupsAmount()
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})

        this.handleFormWithPredefinedGroups()
    }

    disconnect() {
        console.log("Interface groups drag controller disconnected")
    }

    mutate(entries) {

        var groupsAmountAfterMutation = this.currentGroupsAmount()
        var change = this.groupsAmount - groupsAmountAfterMutation

        if (change == 1)  {
            var typeOfChange = 'groupRemoved'
        } else if (change == -1) {
            var typeOfChange = 'groupAdded'
        }

        if (typeOfChange == 'groupAdded') {
            // new group added
            this.recalculateIndexes()
            this.groupsAmount = this.groupsAmount + 1
        } else if (typeOfChange == 'groupRemoved') {
            // group been removed
            this.recalculateIndexes()
            this.groupsAmount = this.groupsAmount - 1
        }
    }


    // PRIVATE

    handleFormWithPredefinedGroups(){
        // For initial control structure we have only hidden field target
        if (this.groupPositionHiddenFieldTargets.length >= 1 ) {
            this.recalculateIndexes()
        }
    }

    currentGroupsAmount(){
        // return this.interfaceGroupsAreaTarget.querySelectorAll('.interface-group-position-hidden-field').length
        return this.groupPositionHiddenFieldTargets.length
    }


    end(event) {
        this.recalculateIndexes()
    }

    recalculateIndexes(){
        // // recount hidden inputs indexes

        // 1.select only visible (hidden steps - deleted steps taken from db to edit form)
        let filteredHiddenFieldTargets = this.groupPositionHiddenFieldTargets.filter((field) => {
            return field.closest(nestedFieldsTemplateSelector).style.display != 'none'
        });

        // 2.update indexes
        // var positionHiddenElemenets = [...this.interfaceGroupsAreaTarget.querySelectorAll(".interface-group-position-hidden-field")]
        var positionHiddenElemenets = [...filteredHiddenFieldTargets]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.value = (index + 1)
        });


        // 1.select only visible (hidden steps - deleted steps taken from db to edit form)
        let filteredVisibleFieldTargets = this.groupPositionVisibleFieldTargets.filter((field) => {
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