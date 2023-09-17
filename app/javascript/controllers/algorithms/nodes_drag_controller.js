import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import {useMutation} from "stimulus-use";

export default class extends Controller {

    static targets = [
        'nodePositionVisibleField',
        'nodePositionHiddenField'
    ];

    connect() {
        console.log("Steps drag controller connected")
        this.sortable = Sortable.create(this.element, {
            group: 'steps',
            animation: 150,
            onEnd: this.end.bind(this),
            filter: ".nodraggablesteps"
        })

        // mutation observer to recalculate indexes when new step is added
        this.stepsAmount = this.currentStepsAmount()
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})

        // case when we load edit form with existing nodes
        this.handleFormWithPredefinedSteps()
    }

    disconnect() {
        console.log("Steps drag controller disconnected")
    }


    mutate(entries) {

        var stepsAmountAfterMutation = this.currentStepsAmount()
        var change = this.stepsAmount - stepsAmountAfterMutation

        if (change == 1)  {
            var typeOfChange = 'stepRemoved'
        } else if (change == -1) {
            var typeOfChange = 'stepAdded'
        }

        if (typeOfChange == 'stepAdded') {
            // new step added
            this.recalculateIndexes()
            this.stepsAmount = this.stepsAmount + 1
        } else if (typeOfChange == 'stepRemoved') {
            // step been removed
            this.recalculateIndexes()
            this.stepsAmount = this.stepsAmount - 1
        }
    }


    // PRIVATE

    handleFormWithPredefinedSteps(){
        // For initial control structure we have only hidden field target
        if (this.nodePositionHiddenFieldTargets.length >= 1 ) {
            this.recalculateIndexes()
        }
    }

    currentStepsAmount(){
        // return this.stepsAreaTarget.querySelectorAll('.step-position-hidden-field').length
        return this.nodePositionHiddenFieldTargets.length
    }

    end(event) {
        this.recalculateIndexes()
    }

    recalculateIndexes(){
        // // 1 recount hidden inputs indexes 1
        // var positionHiddenElemenets = [...this.stepsAreaTarget.querySelectorAll(".step-position-hidden-field")]

        // 1.1 select only visible (hidden steps - deleted steps taken from db to edit form)
        let filteredHiddenFieldTargets = this.nodePositionHiddenFieldTargets.filter((field) => {
            // Case when we have default hidden control structure during algorithm creation
            if (field.id == "algorithm-base-control-structure") {
                return true
            } else {
                // normal case
                return field.closest(".steps-nested-fields").style.display != 'none'
            }
        });

        // 1.2.update indexes
        var positionHiddenElemenets = [...filteredHiddenFieldTargets]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.value = (index + 1)
        });


        // recount visible indexes 2
        // 2.1.select only visible (hidden steps - deleted steps taken from db to edit form)
        let filteredVisibleFieldTargets = this.nodePositionVisibleFieldTargets.filter((field) => {
            return field.closest(".steps-nested-fields").style.display != 'none'
        });

        // var positionHiddenElemenets = [...this.stepsAreaTarget.querySelectorAll(".step-position-visible-field")]
        // 2.2 update indexes
        var positionVisibleElemenets = [...filteredVisibleFieldTargets]
        positionVisibleElemenets.forEach(function callback(value, index) {
            value.innerHTML = (index + 1)
            // value.text(index + 1)
        });
    }

}