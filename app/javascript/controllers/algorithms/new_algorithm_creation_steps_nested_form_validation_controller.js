import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    initialize() {
        console.log("new_algorithm_creation_steps_nested_form_validation_controller: new_algorithm_creation_steps_nested_form_validation_controller controller initialized")
    }


    // Connect method if needed by your app setup
    connect() {
        console.log("new_algorithm_creation_steps_nested_form_validation_controller: new_algorithm_creation_steps_nested_form_validation_controller controller connected")
        this.formElement = this.element.closest("form")
    }

    validateForm(event) {

        console.log("new_algorithm_creation_steps_nested_form_validation_controller: validateForm launched")
        // Find all rendered nested field blocks.
        // Update '.nested-fields-wrapper-class' to match the actual outermost class inside your step partials
        const allStepFields = this.element.querySelectorAll(".steps-nested-fields")

        let activeCount = 0

        allStepFields.forEach((fieldBlock) => {
            // Safely ignore records hidden/marked for destruction by cocoon or custom nested form code
            const destroyInput = fieldBlock.querySelector("input[name*='[_destroy]']")
            const isMarkedForDestroy = destroyInput && destroyInput.value === "1"

            if (!isMarkedForDestroy && fieldBlock.style.display !== "none") {
                activeCount++
            }
        })

        // Block submission if no active fields are mapped
        if (activeCount === 0) {
            // THIS LINE IS CRITICAL TO BLOCK THE BACKEND CALL
            event.preventDefault()

            // Inject or alert a beautiful error status cleanly to the user
            this.renderFrontendError("You must configure at least one active step before saving this algorithm configuration.")
        }
    }

    renderFrontendError(message) {
        // Check if an alert element already exists to prevent duplicate text blocks
        let errorBanner = this.element.querySelector(".js-frontend-error-banner")
        if (!errorBanner) {
            errorBanner = document.createElement("div")
            errorBanner.className = "js-frontend-error-banner mt-4 p-4 text-sm text-red-800 bg-red-50 rounded-xl border-2 border-red-200 font-medium"

            // Create the line break element
            const lineBreak = document.createElement("br")

            // Insert the error banner first, then insert the line break right after it
            this.element.prepend(errorBanner)
            errorBanner.after(lineBreak)
        }
        errorBanner.textContent = message
        errorBanner.scrollIntoView({ behavior: 'smooth' })
    }
}
