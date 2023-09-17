// TODO: rename to dynamic_node_form
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = [
        "dynamicNodeForm",
        "parentOfDynamicNode",
        "currentNodeFrontendId" ]

    initialize() {
        console.log("Dynamic node controller initialized")
        this.setParentNodeIdValue()
        this.setCurrentNodeFronendIdValue()
    }

    connect() {
        console.log("Dynamic node controller connected")
    }

    disconnect() {
        console.log("Dynamic node controller disconnected")
    }

    // PRIVATE METHODS
    setParentNodeIdValue(){

        // Here we go from up to bottom of the form
        // get parent instance key
        var parentForm = this.dynamicNodeFormTarget.closest('.nested-fields');
        console.log("parentForm")
        console.log(parentForm)

        // TODO: use target for step-position-hidden-field
        var firstInputOfParentForm = parentForm.querySelector('.node-position-hidden-field')
        console.log("firstInputOfParentForm")
        console.log(firstInputOfParentForm)

        var idWithInstanceKey = firstInputOfParentForm.id
        console.log("idWithInstanceKey")
        console.log(idWithInstanceKey)

        var instaceKeyList = idWithInstanceKey.split("_")
        if (instaceKeyList[0] == "dynamic") {
            // 1. Case when parent is dynamicly generated step
            var instanceKey = idWithInstanceKey.split("_").at(2)
            console.log("instanceKey (dynamic case)")
            console.log(instanceKey)

            // set this key to hidden field for usage
            this.parentOfDynamicNodeTarget.value = `dynamic_node_${instanceKey}`
            console.log("this.parentOfDynamicNodeTarget.value")
            console.log(this.parentOfDynamicNodeTarget.value)
        } else {
            // 2. When parent normally generated substep
            // a[0].querySelector('.substep-position-hidden-field').id.split("_").at(-2)
            var instanceKey = idWithInstanceKey.split("_").at(-2)
            console.log("instanceKey (normaly gen case)")
            console.log(instanceKey)

            // set this key to hidden field for usage
            this.parentOfDynamicNodeTarget.value = instanceKey
            console.log("this.parentOfDynamicNodeTarget.value")
            console.log(this.parentOfDynamicNodeTarget.value)
        }
    }

    setCurrentNodeFronendIdValue(){
        // Here logic goes from generated input itslef
        // during iteration we create dynamic id with key

        var firstInputId = this.currentNodeFrontendIdTarget.id
        console.log("firstInputId")
        console.log(firstInputId)

        // Get id from that input
        var firstInputInstaceKeyList = firstInputId.split("_")
        console.log("var firstInputInstaceKeyList")
        console.log(firstInputInstaceKeyList)

        if (firstInputInstaceKeyList[0] == "dynamic") {
            // 1. Case when parent is dynamicly generated step
            var firstInputInstaceKey = firstInputId.split("_").at(2)
            console.log("firstInputInstaceKey (dynamic case)")
            console.log(firstInputInstaceKey)
        } else {
            // 2. When parent normally generated substep
            // a[0].querySelector('.step-position-hidden-field').id.split("_").at(-2)
            var firstInputInstaceKey = firstInputId.split("_").at(-2)
            console.log("firstInputInstaceKey (normaly gen case)")
            console.log(firstInputInstaceKey)
        }

        this.currentNodeFrontendIdTarget.value = `dynamic_node_${firstInputInstaceKey}`
    }



}

