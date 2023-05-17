import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import {useMutation} from "stimulus-use";

export default class extends Controller {

    static targets = ['interfaceGroupsArea'];

    connect() {
        console.log("Interface groups drag controller connected")
        this.sortable = Sortable.create(this.element, {
            group: 'interfaceGroup',
            animation: 150,
            onEnd: this.end.bind(this)
            // filter: ".nodraggablesteps"
        })

        // mutation observer to recalculate indexes when new step is added
        this.stepsAmount = this.currentStepsAmount()
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
    }

    disconnect() {
        console.log("Interface groups drag controller disconnected")
    }

    mutate(entries) {

        var stepsAmountAfterMutation = this.currentStepsAmount()
        var change = this.stepsAmount - stepsAmountAfterMutation

        if (change == 1)  {
            var typeOfChange = 'groupRemoved'
        } else if (change == -1) {
            var typeOfChange = 'groupAdded'
        }

        if (typeOfChange == 'groupAdded') {
            // new group added
            this.recalculateIndexes()
            this.stepsAmount = this.stepsAmount + 1
        } else if (typeOfChange == 'groupRemoved') {
            // step been removed
            this.recalculateIndexes()
            this.stepsAmount = this.stepsAmount - 1
        }
    }


    // PRIVATE

    currentStepsAmount(){
        return this.interfaceGroupsAreaTarget.querySelectorAll('.interface-group-position-hidden-field').length
    }

    end(event) {
        this.recalculateIndexes()
    }

    recalculateIndexes(){
        // // recount hidden inputs indexes
        var positionHiddenElemenets = [...this.interfaceGroupsAreaTarget.querySelectorAll(".interface-group-position-hidden-field")]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.value = index + 1
        });

        // recount visible indexes 2
        var positionHiddenElemenets = [...this.interfaceGroupsAreaTarget.querySelectorAll(".interface-group-position-visible-field")]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.innerHTML = (index + 1)
            // value.text(index + 1)
        });
    }



    // end(event) {
    //     console.log("end(event) fired")
    //     this.recalculateIndexes()
    //
    //     let id = event.item.dataset.id
    //     let data = new FormData()
    //     console.log(data)
    //     data.append("position", event.newIndex + 1)
    //
    //     put value in a position field
    //
    //     Rails.ajax({
    //         url: this.data.get("url").replace(":id", id),
    //         type: 'PATCH',
    //         data: data
    //     })
    // }
}