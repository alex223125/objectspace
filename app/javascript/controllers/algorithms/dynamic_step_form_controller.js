import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static targets = ["dynamicStepForm", "parentOfDynamicStep", "currentStepFrontendId" ]

    initialize() {
        console.log("Dynamic step controller initialized")
        this.setParentStepIdValue()
        this.setCurrentStepFronendIdValue()
    }

    connect() {
        console.log("Dynamic step controller connected")
    }

    disconnect() {
        console.log("Dynamic step controller disconnected")
    }

    // PRIVATE METHODS
    setParentStepIdValue(){

        // Here we go from up to bottom of the form
        // get parent instance key
        var parentForm = this.dynamicStepFormTarget.closest('.nested-fields');
        console.log("parentForm")
        console.log(parentForm)

        var firstInputOfParentForm = parentForm.querySelector('.step-position-hidden-field')
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
            this.parentOfDynamicStepTarget.value = `dynamic_step_${instanceKey}`
            console.log("this.parentOfDynamicStepTarget.value")
            console.log(this.parentOfDynamicStepTarget.value)
        } else {
            // 2. When parent normally generated substep
            // a[0].querySelector('.substep-position-hidden-field').id.split("_").at(-2)
            var instanceKey = idWithInstanceKey.split("_").at(-2)
            console.log("instanceKey (normaly gen case)")
            console.log(instanceKey)

            // set this key to hidden field for usage
            this.parentOfDynamicStepTarget.value = instanceKey
            console.log("this.parentOfDynamicStepTarget.value")
            console.log(this.parentOfDynamicStepTarget.value)
        }
    }

    setCurrentStepFronendIdValue(){
        // Here logic goes from generated input itslef
        // during iteration we create dynamic id with key

        var firstInputId = this.currentStepFrontendIdTarget.id
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

        this.currentStepFrontendIdTarget.value = `dynamic_step_${firstInputInstaceKey}`
    }



}

