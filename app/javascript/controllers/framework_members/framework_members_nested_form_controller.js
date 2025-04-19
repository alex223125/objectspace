// TODO: rename to nodes nested form
import { Controller } from '@hotwired/stimulus';
//
// const regularStepType = "regular_step"
// const wrapperStepType = "wrapper_step"
// const containerStepType = "container_step"

const regularFrameworkMember = "regular_member"

const singleAlternativeControlStructureType = "single_alternative_control_structure"

export default class extends Controller {
    static targets = [
        "add_item",
        "regularFrameworkFieldsTemplate"

        // steps
        // "regularStepFieldsTemplate",
        // "wrapperStepFieldsTemplate",
        // "containerStepFieldsTemplate",

        // control structures
        // "singleAlternativeControlStructureFieldsTemplate"
    ]

    initialize() {
        console.log("framework_members_nested_form_controller initialized")
        // this.
    }

    connect() {
        console.log("framework_members_nested_form_controller connected")
    }

    disconnect() {
        console.log("framework_members_nested_form_controller disconnected")
    }

    // PUBLIC METHODS

    add_association(event) {
        console.log("add_association triggered")
        console.log(event.target)

        event.preventDefault()
        // let value = event.target.dataset.value
        let frameworkMemberType = event.target.dataset.frameworkMemberType
        let childIndexKeyword = event.target.dataset.childIndexKeyword

        // means we will get it's content by 'get' request to webservier
        let class_of_template_without_inner_content = 'ghost-class'

        // set content
        if (frameworkMemberType == regularFrameworkMember) {
            if (this.regularFrameworkFieldsTemplateTarget.className == class_of_template_without_inner_content) {
                // var content = this.loadMemberTemplate(frameworkMemberType)
            } else {
                console.log("childIndexKeyword")
                console.log(childIndexKeyword)
                var regExpresion = new RegExp(childIndexKeyword, 'g')

                console.log("this.regularFrameworkFieldsTemplateTarget.innerHTML")
                console.log(this.regularFrameworkFieldsTemplateTarget.innerHTML)

                var content = this.regularFrameworkFieldsTemplateTarget.innerHTML.replace(regExpresion, new Date().valueOf())
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

    // loadMemberTemplate(stepType){
    //     var url = `/framework_member_template?type=${stepType}`
    //
    //     // 4.3 make request
    //     Rails.ajax({
    //         type: 'GET',
    //         url: url,
    //         dataType: 'json',
    //         success: (data) => {
    //             console.log("Template 112233 loaded!")
    //             console.log(data)
    //             // console.log(data.preview)
    //             this.add_itemTarget.insertAdjacentHTML('beforebegin', data.framework_member_template)
    //             // this.insertPreview(data)
    //             // this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
    //         }
    //     })
    // }

}

