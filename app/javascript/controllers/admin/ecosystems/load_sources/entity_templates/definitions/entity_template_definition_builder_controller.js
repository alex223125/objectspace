import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "properties",
        "emptyState",
        "propertyCount",
        "builderStatus",
        "definitionInput",
        "jsonPreview",
        "jsonStatus",
        "progressIcon",
        "progressMessage",
        "progressText",
        "progressBar",
        "submitStatus",
        "submitButton",
        "toast"
    ]

    connect() {
        this.fields = []
        this.nextId = 1

        this.xpValue = 0
        this.toastTimer = null
        this.statusTimer = null

        this.loadExistingDefinition()
        this.render()

        console.log(
            "entity_template_definition_builder connected"
        )
    }

    disconnect() {
        clearTimeout(this.toastTimer)
        clearTimeout(this.statusTimer)
    }

    // ============================================================
    // PUBLIC ACTIONS
    // ============================================================

    addProperty(event) {
        console.log("1. addProperty clicked")

        const type =
            event?.currentTarget?.dataset?.type || "text"

        console.log("2. type:", type)

        this.fields.push({
            id: this.nextId++,
            name: "",
            label: "",
            type: type,
            required: false,
            description: "",
            options: []
        })

        console.log("3. fields:", this.fields)

        this.xpValue += 10

        console.log("4. before render")

        this.render()

        console.log("5. after render")

        this.showStatus(
            `${this.humanizeType(type)} property added`
        )

        console.log("6. after showStatus")

        this.showToast(
            `✨ New ${this.humanizeType(type)} property added`
        )

        console.log("7. after showToast")

        this.focusLastProperty()

        console.log("8. finished addProperty")
    }

    // Backwards compatibility if you have other HTML using addField.
    addField(event) {
        this.addProperty(event)
    }

    addFieldWithType(event) {
        this.addProperty(event)
    }

    removeField(event) {
        const id = Number(
            event.currentTarget.dataset.id
        )

        const index = this.fields.findIndex(
            field => field.id === id
        )

        if (index === -1) {
            return
        }

        this.fields.splice(index, 1)

        this.xpValue += 5

        this.render()

        this.showStatus("Property removed")
        this.showToast("🧹 Property removed")
    }

    moveFieldUp(event) {
        const id = Number(
            event.currentTarget.dataset.id
        )

        const index = this.fields.findIndex(
            field => field.id === id
        )

        if (index <= 0) {
            return
        }

        const current = this.fields[index]

        this.fields.splice(index, 1)
        this.fields.splice(index - 1, 0, current)

        this.render()

        this.showStatus("Property moved up")
    }

    moveFieldDown(event) {
        const id = Number(
            event.currentTarget.dataset.id
        )

        const index = this.fields.findIndex(
            field => field.id === id
        )

        if (
            index === -1 ||
            index >= this.fields.length - 1
        ) {
            return
        }

        const current = this.fields[index]

        this.fields.splice(index, 1)
        this.fields.splice(index + 1, 0, current)

        this.render()

        this.showStatus("Property moved down")
    }

    duplicateField(event) {
        const id = Number(
            event.currentTarget.dataset.id
        )

        const original = this.fields.find(
            field => field.id === id
        )

        if (!original) {
            return
        }

        const copy = {
            ...original,
            id: this.nextId++,
            name: original.name
                ? `${original.name}_copy`
                : "",
            label: original.label
                ? `${original.label} Copy`
                : "",
            options: [
                ...(original.options || [])
            ]
        }

        const index = this.fields.findIndex(
            field => field.id === id
        )

        this.fields.splice(
            index + 1,
            0,
            copy
        )

        this.xpValue += 8

        this.render()

        this.showStatus("Property duplicated")
        this.showToast("🧬 Property duplicated")
    }

    // ============================================================
    // FIELD CHANGES
    // ============================================================

    fieldChanged(event) {
        const element = event.target

        const id = Number(
            element.dataset.id
        )

        const attribute =
            element.dataset.attribute

        if (!attribute) {
            return
        }

        const field = this.fields.find(
            item => item.id === id
        )

        if (!field) {
            return
        }

        if (element.type === "checkbox") {
            field[attribute] = element.checked
        } else {
            field[attribute] = element.value
        }

        this.updateJson()
        this.updateCounters()
        this.updateProgress()

        this.showStatus(
            "Builder updated"
        )
    }

    // ============================================================
    // EXAMPLE TEMPLATES
    // ============================================================

    loadExample() {
        this.loadPersonExample()
    }

    loadPersonExample() {
        this.loadExampleDefinition(
            "Person",
            [
                {
                    name: "first_name",
                    label: "First Name",
                    type: "text",
                    required: true,
                    description: "The person's first name."
                },
                {
                    name: "last_name",
                    label: "Last Name",
                    type: "text",
                    required: true,
                    description: "The person's last name."
                },
                {
                    name: "email",
                    label: "Email",
                    type: "email",
                    required: false,
                    description: "Primary email address."
                },
                {
                    name: "birth_date",
                    label: "Birth Date",
                    type: "date",
                    required: false,
                    description: "Date of birth."
                }
            ]
        )
    }

    loadOrganizationExample() {
        this.loadExampleDefinition(
            "Organization",
            [
                {
                    name: "name",
                    label: "Organization Name",
                    type: "text",
                    required: true,
                    description: "The legal or common name of the organization."
                },
                {
                    name: "website",
                    label: "Website",
                    type: "url",
                    required: false,
                    description: "Official organization website."
                },
                {
                    name: "email",
                    label: "Email",
                    type: "email",
                    required: false,
                    description: "Primary organization email."
                },
                {
                    name: "description",
                    label: "Description",
                    type: "textarea",
                    required: false,
                    description: "Short description of the organization."
                }
            ]
        )
    }

    loadProductExample() {
        this.loadExampleDefinition(
            "Product",
            [
                {
                    name: "name",
                    label: "Product Name",
                    type: "text",
                    required: true,
                    description: "Name of the product."
                },
                {
                    name: "description",
                    label: "Description",
                    type: "textarea",
                    required: false,
                    description: "Description of the product."
                },
                {
                    name: "price",
                    label: "Price",
                    type: "number",
                    required: false,
                    description: "Current product price."
                },
                {
                    name: "image",
                    label: "Product Image",
                    type: "image",
                    required: false,
                    description: "Primary product image."
                }
            ]
        )
    }

    loadLocationExample() {
        this.loadExampleDefinition(
            "Location",
            [
                {
                    name: "name",
                    label: "Location Name",
                    type: "text",
                    required: true,
                    description: "Name of the location."
                },
                {
                    name: "address",
                    label: "Address",
                    type: "textarea",
                    required: false,
                    description: "Street address."
                },
                {
                    name: "city",
                    label: "City",
                    type: "text",
                    required: false,
                    description: "City or locality."
                },
                {
                    name: "country",
                    label: "Country",
                    type: "text",
                    required: false,
                    description: "Country."
                }
            ]
        )
    }

    loadArticleExample() {
        this.loadExampleDefinition(
            "Article",
            [
                {
                    name: "title",
                    label: "Title",
                    type: "text",
                    required: true,
                    description: "Article title."
                },
                {
                    name: "slug",
                    label: "Slug",
                    type: "text",
                    required: true,
                    description: "URL-friendly article identifier."
                },
                {
                    name: "content",
                    label: "Content",
                    type: "textarea",
                    required: true,
                    description: "Main article content."
                },
                {
                    name: "published_at",
                    label: "Published At",
                    type: "datetime",
                    required: false,
                    description: "Publication date and time."
                }
            ]
        )
    }

    loadExampleDefinition(name, definitions) {
        this.fields = definitions.map(field => ({
            id: this.nextId++,
            name: field.name || "",
            label: field.label || "",
            type: field.type || "text",
            required: Boolean(field.required),
            description: field.description || "",
            options: Array.isArray(field.options)
                ? field.options
                : []
        }))

        this.xpValue += 20

        this.render()

        this.showStatus(
            `${name} example loaded`
        )

        this.showToast(
            `✨ ${name} template loaded`
        )
    }

    // ============================================================
    // JSON IMPORT
    // ============================================================

    importJson() {
        if (!this.hasDefinitionInputTarget) {
            return
        }

        const value =
            this.definitionInputTarget.value?.trim()

        if (!value) {
            return
        }

        try {
            const definition = JSON.parse(value)

            if (
                !definition ||
                typeof definition !== "object" ||
                Array.isArray(definition)
            ) {
                throw new Error(
                    "Definition must be an object."
                )
            }

            const fields =
                Array.isArray(definition.fields)
                    ? definition.fields
                    : []

            this.fields = fields.map(field => ({
                id: this.nextId++,
                name: field.name || "",
                label: field.label || "",
                type: field.type || "text",
                required: Boolean(field.required),
                description:
                    field.description || "",
                options:
                    Array.isArray(field.options)
                        ? field.options
                        : []
            }))

            this.xpValue += 20

            this.render()

            this.showStatus(
                "JSON imported"
            )

            this.showToast(
                "📥 JSON imported successfully"
            )
        } catch (error) {
            console.error(
                "Entity Template Builder JSON import error:",
                error
            )

            this.showStatus(
                "Invalid JSON"
            )

            this.showToast(
                "⚠️ Could not import JSON"
            )
        }
    }

    // ============================================================
    // RESET
    // ============================================================

    clearBuilder() {
        if (this.fields.length === 0) {
            return
        }

        if (
            !window.confirm(
                "Remove all properties from this definition?"
            )
        ) {
            return
        }

        this.fields = []

        this.xpValue += 5

        this.render()

        this.showStatus(
            "Builder cleared"
        )

        this.showToast(
            "🧹 Definition cleared"
        )
    }

    // ============================================================
    // SUBMIT
    // ============================================================

    beforeSubmit(event) {
        this.updateJson()

        if (
            this.fields.length === 0
        ) {
            const shouldContinue =
                window.confirm(
                    "This template has no properties. Create it anyway?"
                )

            if (!shouldContinue) {
                event.preventDefault()
                return
            }
        }

        if (this.hasSubmitStatusTarget) {
            this.submitStatusTarget.textContent =
                "Creating template..."
        }

        if (this.hasSubmitButtonTarget) {
            this.submitButtonTarget.disabled = true
            this.submitButtonTarget.classList.add(
                "opacity-60",
                "cursor-not-allowed"
            )
        }
    }

    // ============================================================
    // RENDER
    // ============================================================

    render() {
        this.renderProperties()
        this.updateJson()
        this.updateCounters()
        this.updateProgress()
    }

    renderProperties() {
        if (!this.hasPropertiesTarget) {
            return
        }

        if (this.fields.length === 0) {
            this.propertiesTarget.innerHTML = ""

            if (this.hasEmptyStateTarget) {
                this.emptyStateTarget.classList.remove(
                    "hidden"
                )
            }

            return
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.classList.add(
                "hidden"
            )
        }

        this.propertiesTarget.innerHTML =
            this.fields
                .map(field =>
                    this.renderField(field)
                )
                .join("")
    }

    renderField(field) {
        return `
      <div
        class="
          rounded-2xl
          border
          border-gray-200
          bg-white
          p-5
          shadow-sm
          dark:border-gray-700
          dark:bg-gray-900
        "
        data-field-card="${field.id}"
      >

        <div class="flex items-start justify-between gap-4">

          <div class="flex items-center gap-3">

            <div
              class="
                flex
                h-10
                w-10
                items-center
                justify-center
                rounded-xl
                bg-violet-100
                text-lg
                dark:bg-violet-900/30
              "
            >
              ${this.iconForType(field.type)}
            </div>

            <div>

              <div
                class="
                  text-[10px]
                  font-black
                  uppercase
                  tracking-[0.18em]
                  text-violet-500
                "
              >
                Property ${this.fields.indexOf(field) + 1}
              </div>

              <div
                class="
                  mt-1
                  text-sm
                  font-black
                  text-gray-900
                  dark:text-white
                "
              >
                ${this.escapeHtml(
            field.label || "Unnamed property"
        )}
              </div>

            </div>

          </div>

          <div class="flex items-center gap-1">

            <button
              type="button"
              data-action="click->entity_template_definition_builder#moveFieldUp"
              data-id="${field.id}"
              class="
                rounded-lg
                px-2
                py-1
                text-sm
                hover:bg-gray-100
                dark:hover:bg-gray-800
              "
              title="Move up"
            >
              ↑
            </button>

            <button
              type="button"
              data-action="click->entity_template_definition_builder#moveFieldDown"
              data-id="${field.id}"
              class="
                rounded-lg
                px-2
                py-1
                text-sm
                hover:bg-gray-100
                dark:hover:bg-gray-800
              "
              title="Move down"
            >
              ↓
            </button>

            <button
              type="button"
              data-action="click->entity_template_definition_builder#duplicateField"
              data-id="${field.id}"
              class="
                rounded-lg
                px-2
                py-1
                text-sm
                hover:bg-gray-100
                dark:hover:bg-gray-800
              "
              title="Duplicate"
            >
              ⧉
            </button>

            <button
              type="button"
              data-action="click->entity_template_definition_builder#removeField"
              data-id="${field.id}"
              class="
                rounded-lg
                px-2
                py-1
                text-sm
                text-red-500
                hover:bg-red-50
                dark:hover:bg-red-900/20
              "
              title="Remove"
            >
              ✕
            </button>

          </div>

        </div>

        <div class="mt-5 grid grid-cols-1 gap-4 md:grid-cols-2">

          <div>

            <label
              class="
                mb-2
                block
                text-xs
                font-bold
                text-gray-600
                dark:text-gray-300
              "
            >
              Internal key
            </label>

            <input
              type="text"
              value="${this.escapeAttribute(field.name)}"
              data-id="${field.id}"
              data-attribute="name"
              data-action="input->entity_template_definition_builder#fieldChanged"
              placeholder="first_name"
              class="
                block
                w-full
                rounded-xl
                border
                border-gray-300
                bg-gray-50
                px-3
                py-2.5
                text-sm
                dark:border-gray-700
                dark:bg-gray-800
                dark:text-white
              "
            />

            <p class="mt-1 text-[11px] text-gray-400">
              Machine-readable property name.
            </p>

          </div>

          <div>

            <label
              class="
                mb-2
                block
                text-xs
                font-bold
                text-gray-600
                dark:text-gray-300
              "
            >
              Display label
            </label>

            <input
              type="text"
              value="${this.escapeAttribute(field.label)}"
              data-id="${field.id}"
              data-attribute="label"
              data-action="input->entity_template_definition_builder#fieldChanged"
              placeholder="First Name"
              class="
                block
                w-full
                rounded-xl
                border
                border-gray-300
                bg-gray-50
                px-3
                py-2.5
                text-sm
                dark:border-gray-700
                dark:bg-gray-800
                dark:text-white
              "
            />

          </div>

          <div>

            <label
              class="
                mb-2
                block
                text-xs
                font-bold
                text-gray-600
                dark:text-gray-300
              "
            >
              Property type
            </label>

            <select
              data-id="${field.id}"
              data-attribute="type"
              data-action="change->entity_template_definition_builder#fieldChanged"
              class="
                block
                w-full
                rounded-xl
                border
                border-gray-300
                bg-gray-50
                px-3
                py-2.5
                text-sm
                dark:border-gray-700
                dark:bg-gray-800
                dark:text-white
              "
            >
              ${this.typeOptions(field.type)}
            </select>

          </div>

          <div>

            <label
              class="
                mb-2
                block
                text-xs
                font-bold
                text-gray-600
                dark:text-gray-300
              "
            >
              Required
            </label>

            <label class="flex items-center gap-3 pt-2">

              <input
                type="checkbox"
                ${field.required ? "checked" : ""}
                data-id="${field.id}"
                data-attribute="required"
                data-action="change->entity_template_definition_builder#fieldChanged"
                class="
                  h-5
                  w-5
                  rounded
                  border-gray-300
                  text-violet-600
                  focus:ring-violet-500
                "
              />

              <span
                class="
                  text-sm
                  text-gray-600
                  dark:text-gray-300
                "
              >
                This property is required
              </span>

            </label>

          </div>

        </div>

        <div class="mt-4">

          <label
            class="
              mb-2
              block
              text-xs
              font-bold
              text-gray-600
              dark:text-gray-300
            "
          >
            Description
          </label>

          <textarea
            rows="3"
            data-id="${field.id}"
            data-attribute="description"
            data-action="input->entity_template_definition_builder#fieldChanged"
            placeholder="Explain what this property represents..."
            class="
              block
              w-full
              rounded-xl
              border
              border-gray-300
              bg-gray-50
              px-3
              py-2.5
              text-sm
              dark:border-gray-700
              dark:bg-gray-800
              dark:text-white
            "
          >${this.escapeHtml(field.description)}</textarea>

        </div>

      </div>
    `
    }

    // ============================================================
    // JSON
    // ============================================================

    buildDefinition() {
        return {
            fields: this.fields.map(field => {
                const result = {
                    name: field.name,
                    label: field.label,
                    type: field.type,
                    required: Boolean(field.required)
                }

                if (field.description) {
                    result.description =
                        field.description
                }

                if (
                    Array.isArray(field.options) &&
                    field.options.length > 0
                ) {
                    result.options =
                        field.options
                }

                return result
            })
        }
    }

    updateJson() {
        const definition =
            this.buildDefinition()

        const json =
            JSON.stringify(
                definition,
                null,
                2
            )

        if (this.hasDefinitionInputTarget) {
            this.definitionInputTarget.value = json
        }

        if (this.hasJsonPreviewTarget) {
            this.jsonPreviewTarget.textContent = json
        }

        if (this.hasJsonStatusTarget) {
            this.jsonStatusTarget.textContent =
                "Valid JSON"
        }
    }

    // ============================================================
    // EXISTING DEFINITION
    // ============================================================

    loadExistingDefinition() {
        if (!this.hasDefinitionInputTarget) {
            return
        }

        const value =
            this.definitionInputTarget.value?.trim()

        if (
            !value ||
            value === "{}"
        ) {
            return
        }

        try {
            const definition =
                JSON.parse(value)

            if (
                definition &&
                typeof definition === "object" &&
                Array.isArray(definition.fields)
            ) {
                this.fields =
                    definition.fields.map(field => ({
                        id: this.nextId++,
                        name: field.name || "",
                        label: field.label || "",
                        type: field.type || "text",
                        required: Boolean(
                            field.required
                        ),
                        description:
                            field.description || "",
                        options:
                            Array.isArray(field.options)
                                ? field.options
                                : []
                    }))
            }
        } catch (error) {
            console.warn(
                "Unable to load existing template definition.",
                error
            )
        }
    }

    // ============================================================
    // COUNTERS / PROGRESS
    // ============================================================

    updateCounters() {
        const count = this.fields.length

        if (this.hasPropertyCountTarget) {
            this.propertyCountTarget.textContent =
                `${count} ${count === 1 ? "property" : "properties"}`
        }

        if (this.hasBuilderStatusTarget) {
            this.builderStatusTarget.textContent =
                count === 0
                    ? "Builder ready"
                    : `${count} ${count === 1 ? "property" : "properties"} added`
        }
    }

    updateProgress() {
        const count =
            this.fields.length

        const completed =
            this.fields.filter(field =>
                field.name.trim() &&
                field.label.trim()
            ).length

        let percent = 0

        if (count > 0) {
            percent =
                Math.round(
                    (completed / count) * 100
                )
        }

        if (this.hasProgressTextTarget) {
            this.progressTextTarget.textContent =
                `${percent}%`
        }

        if (this.hasProgressBarTarget) {
            this.progressBarTarget.style.width =
                `${percent}%`
        }

        if (
            this.hasProgressMessageTarget
        ) {
            if (count === 0) {
                this.progressMessageTarget.textContent =
                    "Start building your template"
            } else if (completed === 0) {
                this.progressMessageTarget.textContent =
                    "Add names and labels to your properties"
            } else if (completed < count) {
                this.progressMessageTarget.textContent =
                    "Keep going — your schema is taking shape"
            } else {
                this.progressMessageTarget.textContent =
                    "🎉 Your template is ready"
            }
        }

        if (this.hasProgressIconTarget) {
            if (percent === 100 && count > 0) {
                this.progressIconTarget.textContent = "🎉"
            } else if (count > 0) {
                this.progressIconTarget.textContent = "⚙️"
            } else {
                this.progressIconTarget.textContent = "🧭"
            }
        }
    }

    // ============================================================
    // UI FEEDBACK
    // ============================================================

    showStatus(message) {
        if (!this.hasBuilderStatusTarget) {
            return
        }

        this.builderStatusTarget.textContent =
            message

        clearTimeout(this.statusTimer)

        this.statusTimer =
            setTimeout(() => {
                this.updateCounters()
            }, 1800)
    }

    showToast(message) {
        if (!this.hasToastTarget) {
            return
        }

        this.toastTarget.textContent =
            message

        this.toastTarget.classList.remove(
            "hidden"
        )

        clearTimeout(this.toastTimer)

        this.toastTimer =
            setTimeout(() => {
                this.toastTarget.classList.add(
                    "hidden"
                )
            }, 2200)
    }

    // ============================================================
    // FOCUS
    // ============================================================

    focusLastProperty() {
        if (!this.hasPropertiesTarget) {
            return
        }

        requestAnimationFrame(() => {
            const last =
                this.propertiesTarget.lastElementChild

            if (!last) {
                return
            }

            const input =
                last.querySelector(
                    'input[data-attribute="name"]'
                )

            input?.focus()
        })
    }

    // Backwards compatibility.
    focusLastField() {
        this.focusLastProperty()
    }

    // ============================================================
    // HELPERS
    // ============================================================

    humanizeType(type) {
        return String(type)
            .replace(/_/g, " ")
            .replace(/\b\w/g, char =>
                char.toUpperCase()
            )
    }

    iconForType(type) {
        const icons = {
            text: "🔤",
            textarea: "📝",
            number: "🔢",
            boolean: "☑️",
            date: "📅",
            datetime: "🕐",
            email: "📧",
            url: "🔗",
            select: "🔽",
            multiselect: "☷",
            image: "🖼️",
            file: "📎"
        }

        return icons[type] || "🧩"
    }

    typeOptions(selected) {
        const types = [
            ["text", "Text"],
            ["textarea", "Long text"],
            ["number", "Number"],
            ["boolean", "Boolean"],
            ["date", "Date"],
            ["datetime", "Date & time"],
            ["email", "Email"],
            ["url", "URL"],
            ["select", "Select"],
            ["multiselect", "Multi-select"],
            ["image", "Image"],
            ["file", "File"]
        ]

        return types
            .map(([value, label]) => `
        <option
          value="${this.escapeAttribute(value)}"
          ${value === selected ? "selected" : ""}
        >
          ${this.escapeHtml(label)}
        </option>
      `)
            .join("")
    }

    escapeHtml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;")
    }

    escapeAttribute(value) {
        return this.escapeHtml(value)
    }
}
