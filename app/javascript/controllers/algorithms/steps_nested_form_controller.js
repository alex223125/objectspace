// TODO: rename to nodes nested form
import { Controller } from '@hotwired/stimulus';

const regularStepType = "regular_step"
const wrapperStepType = "wrapper_step"
const containerStepType = "container_step"

const singleAlternativeControlStructureType = "single_alternative_control_structure"

export default class extends Controller {
    static targets = [
        "add_item",
        "template",

        // steps
        "regularStepFieldsTemplate",
        "wrapperStepFieldsTemplate",
        "containerStepFieldsTemplate",

        // control structures
        "singleAlternativeControlStructureFieldsTemplate"

    ]

    initialize() {
        console.log("Steps nested form controller initialized")
        // this.
    }

    connect() {
        console.log("Steps nested form controller connected")
    }

    disconnect() {
        console.log("Steps nested form controller disconnected")
    }

    // PUBLIC METHODS

    add_association(event) {
        console.log("add_association triggered")
        event.preventDefault()
        // let value = event.target.dataset.value
        let nodeType = event.target.dataset.nodeType
        let childIndexKeyword = event.target.dataset.childIndexKeyword

        // means we will get it's content by 'get' request to webservier
        let class_of_template_without_inner_content = 'ghost-class'

        // set content
        if (nodeType == regularStepType) {
            if (this.regularStepFieldsTemplateTarget.className == class_of_template_without_inner_content) {
                var content = this.loadNodeTemplate(nodeType)
            } else {
                console.log("childIndexKeyword")
                console.log(childIndexKeyword)
                var regExpresion = new RegExp(childIndexKeyword,'g')
                var content = this.regularStepFieldsTemplateTarget.innerHTML.replace(regExpresion, new Date().valueOf())
                this.add_itemTarget.insertAdjacentHTML('beforebegin', content)
            }

        } else if (nodeType == wrapperStepType) {
            if (this.wrapperStepFieldsTemplateTarget.className == class_of_template_without_inner_content) {
                var content = this.loadNodeTemplate(nodeType)
            } else {
                var content = this.wrapperStepFieldsTemplateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
                this.add_itemTarget.insertAdjacentHTML('beforebegin', content)
            }

        } else if (nodeType == containerStepType) {
            if (this.containerStepFieldsTemplateTarget.className == class_of_template_without_inner_content) {
                var content = this.loadNodeTemplate(nodeType)
            } else {
                var content = this.containerStepFieldsTemplateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
                this.add_itemTarget.insertAdjacentHTML('beforebegin', content)
            }

        } else if (nodeType == singleAlternativeControlStructureType) {
            if (this.containerStepFieldsTemplateTarget.className == class_of_template_without_inner_content) {
                var content = this.loadNodeTemplate(nodeType)
            } else {
                var content = this.singleAlternativeControlStructureFieldsTemplateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
                this.add_itemTarget.insertAdjacentHTML('beforebegin', content)
            }
        }




        console.log("content124124124124214")
        console.log(content)
    }


    remove_association(event) {
        console.log("remove association triggered")
        event.preventDefault()

        let item = event.target.closest(".nested-fields")
        console.log(item.dataset)

        if (item.dataset.newRecord == "true") {
            item.remove();
        } else {
            item.querySelector("input[name*='_destroy']").value = 1
            item.style.display = 'none'
            // Add indexes recalculation hereo nly for visible steps
        }
    }

    // PRIVATE
    loadNodeTemplate(stepType){
        var url = `/node_template?type=${stepType}`

        // 4.3 make request
        Rails.ajax({
            type: 'GET',
            url: url,
            dataType: 'json',
            success: (data) => {
                console.log("Template 112233 loaded!")
                console.log(data)
                // console.log(data.preview)
                this.add_itemTarget.insertAdjacentHTML('beforebegin', data.substep_template)
                // this.insertPreview(data)
                // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
            }
        })
    }

}

