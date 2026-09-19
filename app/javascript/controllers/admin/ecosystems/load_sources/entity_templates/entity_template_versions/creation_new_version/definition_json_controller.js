import { Controller } from "@hotwired/stimulus"

import {
    validateJSON
} from "../../../../../../../libs/entity_definition_validator"

export default class extends Controller {
    static targets = [
        "input",
        "status",
        "error",
        "errorMessage"
    ]

    connect() {
        this.lastValidObject = null
        this.validationTimer = null
        this.initialValidationStarted = false
        this.statusElement = null
        this.statusTargetClaimed = false

        /*
         * The status badge can be shared with
         * entity-definition-builder.
         *
         * This controller is the single owner of the visible
         * JSON status so the builder cannot overwrite:
         *
         * INVALID DEFINITION
         *
         * with:
         *
         * VALID JSON
         */
        this.claimStatusTarget()

        /*
         * Never trust a server-rendered "VALID JSON" label.
         *
         * The textarea value is always the source of truth.
         */
        this.setCheckingState()

        /*
         * The builder may populate the textarea during its own
         * initialization. Validate after the current rendering
         * cycle has completed.
         */
        window.requestAnimationFrame(() => {
            window.requestAnimationFrame(() => {
                this.initialValidationStarted = true
                this.validate(false)
            })
        })
    }

    disconnect() {
        clearTimeout(this.validationTimer)

        /*
         * Restore the builder target if the controller is removed.
         *
         * This keeps Turbo/controller lifecycle behavior safe.
         */
        if (
            this.statusTargetClaimed &&
            this.statusElement &&
            !this.statusElement.hasAttribute(
                "data-entity-definition-builder-target"
            )
        ) {
            this.statusElement.setAttribute(
                "data-entity-definition-builder-target",
                "jsonStatus"
            )
        }
    }

    /*
     * ------------------------------------------------------------
     * STATUS TARGET OWNERSHIP
     * ------------------------------------------------------------
     */

    claimStatusTarget() {
        if (!this.hasStatusTarget) {
            return
        }

        this.statusElement = this.statusTarget
        this.statusTargetClaimed = true

        /*
         * The same element may have both:
         *
         * data-definition-json-target="status"
         *
         * and:
         *
         * data-entity-definition-builder-target="jsonStatus"
         *
         * Remove only the builder target from this shared status
         * element. Do not touch any other builder target.
         */
        if (
            this.statusElement.hasAttribute(
                "data-entity-definition-builder-target"
            )
        ) {
            this.statusElement.removeAttribute(
                "data-entity-definition-builder-target"
            )
        }
    }

    /*
     * ------------------------------------------------------------
     * INPUT CHANGES
     * ------------------------------------------------------------
     */

    changed() {
        clearTimeout(this.validationTimer)

        this.setWorkingState()

        this.validationTimer = setTimeout(() => {
            this.validate(true)
        }, 250)
    }

    /*
     * ------------------------------------------------------------
     * MAIN VALIDATION
     * ------------------------------------------------------------
     *
     * There are deliberately three different states:
     *
     * VALID JSON
     *   JSON syntax is valid AND definition rules are valid.
     *
     * INVALID JSON
     *   JSON.parse() failed.
     *
     * INVALID DEFINITION
     *   JSON.parse() succeeded but definition rules failed.
     */

    validate(emit = true) {
        if (!this.hasInputTarget) {
            return false
        }

        const raw = this.inputTarget.value.trim()

        /*
         * Empty input is not a valid definition.
         */
        if (!raw) {
            this.lastValidObject = null

            this.setInvalidDefinition(
                "Definition cannot be empty."
            )

            return false
        }

        /*
         * --------------------------------------------------------
         * STEP 1: REAL JSON SYNTAX
         * --------------------------------------------------------
         */

        let parsed

        try {
            parsed = JSON.parse(raw)
        } catch (error) {
            /*
             * Try the existing safe structural repair logic.
             *
             * Importantly, repaired JSON still has to pass the
             * actual definition validator before it can become valid.
             */
            const repaired = this.trySafeRepair(raw)

            if (repaired) {
                try {
                    const repairedParsed = JSON.parse(repaired)

                    const validation = validateJSON(repaired)

                    /*
                     * Repaired JSON is completely valid.
                     */
                    if (
                        validation.parseValid &&
                        validation.schemaValid
                    ) {
                        const definition =
                            validation.definition ||
                            repairedParsed

                        this.inputTarget.value =
                            JSON.stringify(
                                definition,
                                null,
                                2
                            )

                        this.lastValidObject =
                            definition

                        this.setValid("AUTO-REPAIRED")

                        if (emit) {
                            this.dispatch(
                                "valid",
                                {
                                    detail: {
                                        definition,
                                        source: "json-repaired"
                                    }
                                }
                            )
                        }

                        return true
                    }

                    /*
                     * The repair succeeded syntactically, but the
                     * resulting definition is still invalid.
                     *
                     * Therefore this is INVALID DEFINITION,
                     * NOT INVALID JSON.
                     */
                    if (
                        validation.parseValid &&
                        !validation.schemaValid
                    ) {
                        this.lastValidObject = null

                        this.setInvalidDefinition(
                            this.buildDefinitionValidationMessage(
                                validation
                            )
                        )

                        return false
                    }
                } catch (_) {
                    /*
                     * Fall through to normal INVALID JSON handling.
                     */
                }
            }

            this.lastValidObject = null

            this.setInvalidJSON(
                this.formatSyntaxError(
                    error,
                    raw
                )
            )

            return false
        }

        /*
         * --------------------------------------------------------
         * STEP 2: DEFINITION VALIDATION
         * --------------------------------------------------------
         *
         * JSON.parse() succeeded.
         *
         * Therefore the JSON is syntactically valid.
         *
         * Now the definition itself must be checked.
         */

        const validation = validateJSON(raw)

        /*
         * Keep this explicit check in case the shared validator
         * implementation changes later.
         */
        if (!validation.parseValid) {
            this.lastValidObject = null

            this.setInvalidJSON(
                this.buildDefinitionValidationMessage(
                    validation
                )
            )

            return false
        }

        /*
         * This is the important distinction:
         *
         * JSON is valid, but the definition is not.
         *
         * Example:
         *
         * {
         *   "fields": [
         *     {
         *       "name": "First Name"
         *     }
         *   ]
         * }
         *
         * JSON.parse() succeeds.
         *
         * Therefore this must NEVER be shown as:
         *
         * INVALID JSON
         *
         * It must be:
         *
         * INVALID DEFINITION
         */
        if (!validation.schemaValid) {
            this.lastValidObject = null

            this.setInvalidDefinition(
                this.buildDefinitionValidationMessage(
                    validation
                )
            )

            return false
        }

        /*
         * --------------------------------------------------------
         * STEP 3: COMPLETELY VALID
         * --------------------------------------------------------
         */

        const definition =
            validation.definition || parsed

        this.lastValidObject = definition

        this.setValid()

        if (emit) {
            this.dispatch(
                "valid",
                {
                    detail: {
                        definition,
                        source: "json"
                    }
                }
            )
        }

        return true
    }

    /*
     * ------------------------------------------------------------
     * FORMAT JSON
     * ------------------------------------------------------------
     */

    format() {
        if (!this.hasInputTarget) {
            return false
        }

        const raw = this.inputTarget.value.trim()

        if (!raw) {
            this.setInvalidDefinition(
                "Definition cannot be empty."
            )

            return false
        }

        try {
            const parsed = JSON.parse(raw)

            const validation = validateJSON(raw)

            if (!validation.parseValid) {
                this.setInvalidJSON(
                    "The definition contains invalid JSON."
                )

                return false
            }

            if (!validation.schemaValid) {
                this.setInvalidDefinition(
                    this.buildDefinitionValidationMessage(
                        validation
                    )
                )

                return false
            }

            const definition =
                validation.definition || parsed

            this.inputTarget.value =
                JSON.stringify(
                    definition,
                    null,
                    2
                )

            this.lastValidObject = definition

            this.setValid("FORMATTED")

            this.dispatch(
                "formatted",
                {
                    detail: {
                        definition
                    }
                }
            )

            return true
        } catch (error) {
            this.setInvalidJSON(
                this.formatSyntaxError(
                    error,
                    raw
                )
            )

            return false
        }
    }

    /*
     * ------------------------------------------------------------
     * SET JSON FROM OBJECT
     * ------------------------------------------------------------
     */

    setFromObject(object) {
        if (!this.hasInputTarget) {
            return false
        }

        this.inputTarget.value =
            JSON.stringify(
                object,
                null,
                2
            )

        /*
         * Never blindly mark the object as valid.
         *
         * Run the exact same validation path as normal input.
         */
        return this.validate(true)
    }

    /*
     * ------------------------------------------------------------
     * GET OBJECT
     * ------------------------------------------------------------
     */

    getObject() {
        if (!this.hasInputTarget) {
            return null
        }

        try {
            return JSON.parse(
                this.inputTarget.value
            )
        } catch (_) {
            return null
        }
    }

    /*
     * ------------------------------------------------------------
     * BACKWARDS-COMPATIBLE STRUCTURE VALIDATION
     * ------------------------------------------------------------
     */

    validateStructure(definition) {
        try {
            const validation =
                validateJSON(
                    JSON.stringify(definition)
                )

            if (!validation.parseValid) {
                return (
                    validation.errors?.[0]?.message ||
                    "Definition contains invalid JSON."
                )
            }

            if (!validation.schemaValid) {
                return (
                    validation.errors?.[0]?.message ||
                    validation.warnings?.[0]?.message ||
                    "Definition does not match the required schema."
                )
            }

            return null
        } catch (error) {
            return (
                error?.message ||
                "Definition validation failed."
            )
        }
    }

    /*
     * ------------------------------------------------------------
     * VALIDATION MESSAGE
     * ------------------------------------------------------------
     */

    buildDefinitionValidationMessage(validation) {
        if (!validation) {
            return "Definition validation failed."
        }

        const errors =
            Array.isArray(validation.errors)
                ? validation.errors
                : []

        const warnings =
            Array.isArray(validation.warnings)
                ? validation.warnings
                : []

        if (errors.length > 0) {
            const firstError = errors[0]

            const path =
                firstError?.path
                    ? `${firstError.path}: `
                    : ""

            return (
                `${path}${firstError?.message || "Definition validation failed."}`
            )
        }

        if (warnings.length > 0) {
            const firstWarning = warnings[0]

            const path =
                firstWarning?.path
                    ? `${firstWarning.path}: `
                    : ""

            return (
                `${path}${firstWarning?.message || "Definition validation warning."}`
            )
        }

        return (
            "The JSON is syntactically valid, but the definition does not match the rules required by the visual builder."
        )
    }

    /*
     * ------------------------------------------------------------
     * SAFE JSON REPAIR
     * ------------------------------------------------------------
     */

    trySafeRepair(raw) {
        let repaired = raw

        /*
         * Convert smart double quotes to normal JSON quotes.
         */
        repaired =
            repaired
                .replace(
                    /[“”]/g,
                    '"'
                )
                .replace(
                    /[‘’]/g,
                    "'"
                )

        /*
         * Remove trailing commas before closing objects/arrays.
         */
        repaired =
            repaired.replace(
                /,\s*([}\]])/g,
                "$1"
            )

        if (repaired === raw) {
            return null
        }

        return repaired
    }

    /*
     * ------------------------------------------------------------
     * JSON SYNTAX ERROR
     * ------------------------------------------------------------
     */

    formatSyntaxError(error, raw) {
        let message =
            error?.message ||
            "Invalid JSON."

        const positionMatch =
            message.match(
                /position\s+(\d+)/i
            )

        if (positionMatch) {
            const position =
                Number(
                    positionMatch[1]
                )

            const before =
                raw.slice(
                    0,
                    position
                )

            const line =
                before.split("\n").length

            const lastNewline =
                before.lastIndexOf("\n")

            const column =
                position -
                lastNewline

            message =
                `${message} Line ${line}, column ${column}.`
        }

        return message
    }

    /*
     * ------------------------------------------------------------
     * STATUS: CHECKING
     * ------------------------------------------------------------
     */

    setCheckingState() {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                "CHECKING..."

            this.statusTarget.className =
                "rounded-full border border-amber-500/20 bg-amber-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-amber-400"
        }

        this.hideError()
    }

    /*
     * ------------------------------------------------------------
     * STATUS: WORKING
     * ------------------------------------------------------------
     */

    setWorkingState() {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                "CHECKING..."

            this.statusTarget.className =
                "rounded-full border border-amber-500/20 bg-amber-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-amber-400"
        }

        this.hideError()
    }

    /*
     * ------------------------------------------------------------
     * STATUS: VALID
     * ------------------------------------------------------------
     *
     * Green is ONLY allowed when:
     *
     * JSON syntax is valid
     * AND
     * definition validation is valid.
     */

    setValid(label = "VALID JSON") {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                label

            this.statusTarget.className =
                "rounded-full border border-emerald-500/20 bg-emerald-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-emerald-400"
        }

        this.hideError()
    }

    /*
     * ------------------------------------------------------------
     * STATUS: INVALID JSON
     * ------------------------------------------------------------
     *
     * Use this ONLY when JSON.parse() fails.
     */

    setInvalidJSON(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                "INVALID JSON"

            this.statusTarget.className =
                "rounded-full border border-red-500/20 bg-red-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-red-400"
        }

        this.showError(message)

        this.dispatch(
            "invalid",
            {
                detail: {
                    message,
                    type: "json"
                }
            }
        )
    }

    /*
     * ------------------------------------------------------------
     * STATUS: INVALID DEFINITION
     * ------------------------------------------------------------
     *
     * Use this when JSON.parse() succeeds but the definition
     * validator rejects the structure/content.
     */

    setInvalidDefinition(message) {
        if (this.hasStatusTarget) {
            this.statusTarget.textContent =
                "INVALID DEFINITION"

            this.statusTarget.className =
                "rounded-full border border-red-500/20 bg-red-500/10 px-3 py-1.5 text-[8px] font-black uppercase tracking-wider text-red-400"
        }

        this.showError(message)

        this.dispatch(
            "invalid",
            {
                detail: {
                    message,
                    type: "definition"
                }
            }
        )
    }

    /*
     * ------------------------------------------------------------
     * BACKWARDS COMPATIBILITY
     * ------------------------------------------------------------
     *
     * Existing code may still call setInvalid().
     *
     * Preserve that API, but treat it as a definition error.
     */

    setInvalid(message) {
        this.setInvalidDefinition(message)
    }

    /*
     * ------------------------------------------------------------
     * ERROR UI
     * ------------------------------------------------------------
     */

    showError(message) {
        if (this.hasErrorTarget) {
            this.errorTarget.classList.remove(
                "hidden"
            )
        }

        if (this.hasErrorMessageTarget) {
            this.errorMessageTarget.textContent =
                message
        }
    }

    hideError() {
        if (this.hasErrorTarget) {
            this.errorTarget.classList.add(
                "hidden"
            )
        }
    }
}