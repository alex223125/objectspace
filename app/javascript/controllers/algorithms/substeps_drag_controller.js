// import { Controller } from "@hotwired/stimulus"
// // import { useMutation } from 'stimulus-use'
// // import { post } from '@rails/request.js'
// require("dragula/dist/dragula.min.css")
//
// import dragula from 'dragula';
// // window.dragula = dragula;
//
//
// export default class extends Controller {
//
//     // static targets = ['substepElement'];
//
//     // static values = {
//     //     reorderPath: String,
//     //     saveOnReorder: { type: Boolean, default: true }
//     // }
//
//     // will be reissued as native dom events name prepended with 'sortable:' e.g. 'sortable:drag', 'sortable:drop', etc
//     // static pluginEventsToReissue = [ "drag", "dragend", "drop", "cancel", "remove", "shadow", "over", "out", "cloned" ]
//
//     connect() {
//         // if (!this.hasReorderPathValue) { return }
//         this.initPluginInstance()
//
//         // useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
//     }
//
//     disconnect() {
//         this.teardownPluginInstance()
//     }
//
//     // mutate(entries) {
//     //     this.plugin.containers =
//     //
//     // }
//
//     initPluginInstance() {
//         const self = this
//         this.plugin = dragula([this.element], {
//             moves: function(el, container, handle) {
//                 console.log("moves triggered")
//                 return true;
//                 // var $handles = $(el).find('.reorder-handle')
//                 // if ($handles.length) {
//                 //     return !!$(handle).closest('.reorder-handle').length
//                 // } else {
//                 //     if (!$(handle).closest('.undraggable').length) {
//                 //         return self.element === container
//                 //     } else {
//                 //         return false
//                 //     }
//                 // }
//             },
//             accepts: function (el, target, source, sibling) {
//                 console.log("accept triggered")
//                 return true;
//                 // if ($(sibling).hasClass('undraggable') && $(sibling).prev().hasClass('undraggable')) {
//                 //     return false
//                 // } else {
//                 //     return true
//                 // }
//             },
//         }).on('drop', function (el) {
//             // save order here.
//             console.log("on drop triggered")
//             // if (self.saveOnReorderValue) {
//             //     self.saveSortOrder()
//             // }
//
//
//         }).on('over', function (el, container) {
//             console.log("on over triggered")
//             // deselect any text fields, or else things go slow!
//             $(document.activeElement).blur()
//         })
//
//         // this.initReissuePluginEventsAsNativeEvents()
//     }
//
//     // initReissuePluginEventsAsNativeEvents() {
//     //     this.constructor.pluginEventsToReissue.forEach((eventName) => {
//     //         this.plugin.on(eventName, (...args) => {
//     //             this.dispatch(eventName, { detail: { plugin: 'dragula', type: eventName, args: args }})
//     //         })
//     //     })
//     // }
//
//     teardownPluginInstance() {
//         if (this.plugin === undefined) { return }
//
//         // revert to original markup, remove any event listeners
//         this.plugin.destroy()
//     }
//
//     // saveSortOrder() {
//     //     var idsInOrder = Array.from(this.element.childNodes).map((el) => { return parseInt(el.dataset?.id) });
//     //
//     //     post(this.reorderPathValue, { body: JSON.stringify({ids_in_order: idsInOrder}) })
//     // }
//
// }




import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"
import {useMutation} from "stimulus-use";

export default class extends Controller {

    static targets = ['substepsArea'];

    connect() {
        console.log("Substep drag controller connected")
        this.sortable = Sortable.create(this.element, {
            group: 'substeps',
            animation: 150,
            onEnd: this.end.bind(this),
            filter: ".nodraggablesubsteps"
        })

        // mutation observer to recalculate indexes when new step is added
        this.stepsAmount = this.currentStepsAmount()
        useMutation(this, {attributes: false, childList: true, characterData: false, subtree:true})
    }

    disconnect() {
        console.log("Substeps drag controller disconnected")
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

    currentStepsAmount(){
        return this.substepsAreaTarget.querySelectorAll('.substep-position-hidden-field').length
    }

    end(event) {
        this.recalculateIndexes()
    }

    recalculateIndexes(){
        // // recount hidden inputs indexes
        var positionHiddenElemenets = [...this.substepsAreaTarget.querySelectorAll(".substep-position-hidden-field")]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.value = index + 1
        });

        // recount visible indexes 2
        var positionHiddenElemenets = [...this.substepsAreaTarget.querySelectorAll(".substep-position-visible-field")]
        positionHiddenElemenets.forEach(function callback(value, index) {
            value.innerHTML = (index + 1)
            // value.text(index + 1)
        });
    }

}