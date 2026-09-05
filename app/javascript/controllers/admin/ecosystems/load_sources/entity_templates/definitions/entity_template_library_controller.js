// entity_template_library_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        templates: Object
    }

    select(event) {
        const key =
            event.currentTarget.dataset.templateKey

        const template =
            this.templatesValue[key]

        if (!template) {
            return
        }

        this.dispatch(
            "selected",
            {
                detail: {
                    template
                }
            }
        )
    }
}
