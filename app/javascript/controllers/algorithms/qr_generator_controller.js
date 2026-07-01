// app/javascript/controllers/qr_generator_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    // FIX: Purge formatSvg and formatPdf targets from this array completely
    static targets = [ "previewFrame" ]
    static values = { versionId: String, algorithmId: String }

    connect() {
        console.log("QR GENERATOR CONTROLLER connected")
        // Ensure everything cleanly sets up here without breaking if elements are missing
        if (!this.hasSubmitButtonTarget) return;

        this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    }

    async generateAndDownload(event) {
        event.preventDefault()

        const formElement = event.target
        this.submitButton = formElement.querySelector('input[type="submit"]') || formElement.querySelector('button[type="submit"]')
        this.setLoading(true)

        // FIX: Fallback lookup strategy. If the controller data value is blank,
        // scrape the ID directly out of your form's hidden version attributes input field!
        let versionId = this.versionIdValue
        if (!versionId || versionId.trim() === "") {
            const hiddenIdInput = formElement.querySelector('input[name*="[id]"]')
            versionId = hiddenIdInput ? hiddenIdInput.value : ""
        }

        // Abort execution safely if both lookup sources evaluate to blank to prevent invalid HTTP queries
        if (!versionId || versionId.trim() === "") {
            console.error("Operational Exception: Target Version ID context token is blank.")
            alert("System initialization trace incomplete. Please reload the wizard stage tab.")
            this.setLoading(false)
            return
        }




        // Option B: Fallback directly to the clicked element's dataset if not using static values
        if (!versionId) {
            versionId = event.currentTarget.dataset.qrGeneratorVersionIdValue
        }

        // Check if it's still missing before running your logic
        if (!versionId) {
            console.error("Operational Exception: Target Version ID context token is blank.");
            return;
        }





        const formData = new FormData(formElement)
        let title = ""
        let description = ""
        for (let [key, value] of formData.entries()) {
            if (key.includes("[print_title]")) title = value
            if (key.includes("[short_print_description]")) description = value
        }

        const selectedFormatElement = formElement.querySelector('input[name="export_format"]:checked')
        const format = selectedFormatElement ? selectedFormatElement.value : "svg"

        try {
            // FIX: Reference the safe versionId parameter identifier variable directly inside the path template string
            const response = await fetch(`/api/algorithm_versions/${versionId}/generate_passport`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": this.csrfToken,
                    "Accept": "application/json"
                },
                body: JSON.stringify({
                    print_title: title,
                    short_print_description: description,
                    export_format: format
                })
            })

            if (!response.ok) throw new Error("Network asset compilation failed.")
            const data = await response.json()

            if (this.hasPreviewFrameTarget) {
                this.previewFrameTarget.innerHTML = `
        <div class="w-36 h-36 flex items-center justify-center bg-white rounded shadow-sm border border-slate-100 p-2 transition-transform duration-300 hover:scale-105">
          ${data.inline_svg}
        </div>
      `
            }

            const binaryString = window.atob(data.binary_file)
            const bytes = new Uint8Array(binaryString.length)
            for (let i = 0; i < binaryString.length; i++) {
                bytes[i] = binaryString.charCodeAt(i)
            }

            const blobType = format === "pdf" ? "application/pdf" : "image/svg+xml"
            const blob = new Blob([bytes], { type: blobType })
            const link = document.createElement("a")
            link.href = window.URL.createObjectURL(blob)
            link.download = `passport_blueprint_${versionId}.${format}`
            link.click()

        } catch (error) {
            console.error(error)
            alert("Error generating asset components.")
        } finally {
            this.setLoading(false)
        }
    }

    // // Add this method to your existing qr_generator controller
    // syncDataToHiddenFields(event) {
    //     // Find the interactive inputs from your visible form (Form 1)
    //     const sourceTitle = this.hasTitleInputTarget ? this.titleInputTarget.value : ""
    //     const sourceDesc = this.hasDescriptionInputTarget ? this.descriptionInputTarget.value : ""
    //
    //     // Find the hidden inputs belonging to your separate save form (Form 2)
    //     const hiddenTitle = document.getElementById("hidden_print_title")
    //     const hiddenDesc = document.getElementById("hidden_short_description")
    //
    //     // Copy values across forms before submission occurs
    //     if (hiddenTitle) hiddenTitle.value = sourceTitle
    //     if (hiddenDesc) hiddenDesc.value = sourceDesc
    // }


    syncDataToHiddenFields(event) {
        // 1. Sync your visible text inputs to the hidden inputs as done previously
        const sourceTitle = this.hasTitleInputTarget ? this.titleInputTarget.value : ""
        const hiddenTitle = document.getElementById("hidden_print_title")
        if (hiddenTitle) hiddenTitle.value = sourceTitle

        // ... sync other fields like description if necessary ...

        // 2. Find the target form
        const form = document.getElementById("isolated-save-state-form")
        if (!form) return

        // 3. Extract the parameters stored on the button's data attributes
        const button = event.currentTarget
        const wizardId = button.dataset.wizardId
        const algorithmId = button.dataset.algorithmId
        const versionId = button.dataset.algorithmVersionId

        // 4. Construct the path ensuring wizard_id follows the base path segment
        // Target format: /algorithm/simple_algorithm_version_creation/[wizard_id]?params...
        const basePath = "/algorithm/simple_algorithm_version_creation"
        const dynamicUrl = `${basePath}/${wizardId}?algorithm_id=${algorithmId}&algorithm_version_id=${versionId}`

        // 5. Override the form action URL dynamically right before submission
        form.action = dynamicUrl

        // The form will now naturally submit via PUT to this exact newly constructed URL
    }



    syncDataAndSubmit(event) {
        event.preventDefault();

        // 1. Sync input values across forms
        const sourceTitle = this.hasTitleInputTarget ? this.titleInputTarget.value : "";
        const hiddenTitle = document.getElementById("form_two_print_title"); // Ensure this matches your form 2 hidden ID
        if (hiddenTitle) hiddenTitle.value = sourceTitle;

        // 2. Find the isolated save form
        const form = document.getElementById("isolated-save-state-form");
        if (!form) return;

        // 3. Extract metadata from the button dataset
        const button = event.currentTarget;
        const wizardId = button.dataset.wizardId; // This evaluates to "qr_code_content"
        const algorithmId = button.dataset.algorithmId;
        const versionId = button.dataset.algorithmVersionId;

        // 4. Correctly place 'wizardId' directly inside the path URL segment!
        const structuredUrl = `/algorithm/simple_algorithm_version_creation/${wizardId}?algorithm_id=${algorithmId}&algorithm_version_id=${versionId}`;

        // 5. Update form action destination and submit
        form.action = structuredUrl;
        form.requestSubmit();
    }






    submitPutForm(event) {

        event.stopPropagation()

        const button = event.currentTarget
        const form = button.closest("form")
        if (!form) return

        form.requestSubmit(button)
    }

    setLoading(isLoading) {
        if (!this.submitButton) return

        if (isLoading) {
            this.submitButton.disabled = true
            this.submitButton.classList.add("opacity-70", "cursor-wait")
            if (this.submitButton.tagName === "INPUT") {
                this.submitButton.value = "⏳ Compiling Media Arrays..."
            } else {
                this.submitButton.innerHTML = "<span>⏳ Compiling Media Arrays...</span>"
            }
        } else {
            this.submitButton.disabled = false
            this.submitButton.classList.remove("opacity-70", "cursor-wait")
            if (this.submitButton.tagName === "INPUT") {
                this.submitButton.value = "📥 Download Print Manifest Sheet"
            } else {
                this.submitButton.innerHTML = "<span>📥 Download Print Manifest Sheet</span>"
            }
        }
    }
}
