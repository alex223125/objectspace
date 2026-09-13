import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "modal",
        "grid",
        "search",
        "preview",
        "previewTitle",
        "previewDescription",
        "previewJson"
    ]

    connect() {
        this.templates = this.buildTemplates()
        this.selectedTemplate = null

        this.render()
    }

    open() {
        this.render()

        this.modalTarget.classList.remove("hidden")
        document.body.classList.add("overflow-hidden")
    }

    close() {
        this.modalTarget.classList.add("hidden")
        document.body.classList.remove("overflow-hidden")
    }

    searchChanged() {
        this.render()
    }

    select(event) {
        const id = event.currentTarget.dataset.templateId

        this.selectedTemplate =
            this.templates.find(template => template.id === id)

        this.renderPreview()
    }

    apply() {
        if (!this.selectedTemplate) return

        this.dispatch("apply", {
            detail: {
                template: this.selectedTemplate.definition,
                title: this.selectedTemplate.title
            }
        })

        this.close()
    }

    render() {
        if (!this.hasGridTarget) return

        const query = this.hasSearchTarget
            ? this.searchTarget.value.trim().toLowerCase()
            : ""

        const templates = this.templates.filter(template => {
            if (!query) return true

            return [
                template.title,
                template.description,
                template.category
            ]
                .join(" ")
                .toLowerCase()
                .includes(query)
        })

        this.gridTarget.innerHTML = templates.map(template => `
      <button
        type="button"
        data-template-id="${template.id}"
        data-action="click->definition-library#select"
        class="
          group
          rounded-3xl
          border-2
          ${this.selectedTemplate?.id === template.id
            ? "border-violet-400 bg-violet-50"
            : "border-slate-100 bg-white"}
          p-5
          text-left
          transition
          hover:-translate-y-1
          hover:border-violet-300
          hover:shadow-lg
        "
      >
        <div class="flex items-start justify-between gap-3">
          <div class="
            flex
            h-11
            w-11
            items-center
            justify-center
            rounded-2xl
            ${template.color}
            text-lg
          ">
            ${template.icon}
          </div>

          <span class="
            rounded-full
            border
            border-slate-100
            bg-white
            px-2
            py-1
            text-[8px]
            font-black
            uppercase
            tracking-wider
            text-slate-400
          ">
            ${template.category}
          </span>
        </div>

        <div class="mt-4 text-sm font-black text-slate-700">
          ${template.title}
        </div>

        <div class="mt-1 text-[10px] leading-5 text-slate-400">
          ${template.description}
        </div>

        <div class="mt-4 flex items-center justify-between">
          <span class="text-[8px] font-black uppercase tracking-wider text-violet-400">
            ${template.definition.fields.length} fields
          </span>

          <span class="text-xs font-black text-violet-500">
            →
          </span>
        </div>
      </button>
    `).join("")

        this.renderPreview()
    }

    renderPreview() {
        if (!this.hasPreviewTarget) return

        if (!this.selectedTemplate) {
            this.previewTarget.classList.add("hidden")
            return
        }

        this.previewTarget.classList.remove("hidden")

        this.previewTitleTarget.textContent =
            this.selectedTemplate.title

        this.previewDescriptionTarget.textContent =
            this.selectedTemplate.description

        this.previewJsonTarget.textContent =
            JSON.stringify(this.selectedTemplate.definition, null, 2)
    }

    buildTemplates() {
        return [
            {
                id: "person",
                title: "Person",
                category: "Identity",
                icon: "👤",
                color: "bg-violet-50 text-violet-500",
                description: "A general person or individual entity.",
                definition: {
                    fields: [
                        {
                            name: "first_name",
                            label: "First name",
                            type: "string",
                            description: "Person first name",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "last_name",
                            label: "Last name",
                            type: "string",
                            description: "Person last name",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "email",
                            label: "Email",
                            type: "email",
                            description: "Primary email address",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "phone",
                            label: "Phone",
                            type: "string",
                            description: "Primary phone number",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "birth_date",
                            label: "Birth date",
                            type: "date",
                            description: "Date of birth",
                            required: false,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "organization",
                title: "Organization",
                category: "Business",
                icon: "🏢",
                color: "bg-sky-50 text-sky-500",
                description: "Company, institution or organization.",
                definition: {
                    fields: [
                        {
                            name: "name",
                            label: "Organization name",
                            type: "string",
                            description: "Official organization name",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "legal_name",
                            label: "Legal name",
                            type: "string",
                            description: "Registered legal name",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "website",
                            label: "Website",
                            type: "url",
                            description: "Official website",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "email",
                            label: "Email",
                            type: "email",
                            description: "Primary organization email",
                            required: false,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "product",
                title: "Product",
                category: "Commerce",
                icon: "📦",
                color: "bg-orange-50 text-orange-500",
                description: "Product or catalog item.",
                definition: {
                    fields: [
                        {
                            name: "sku",
                            label: "SKU",
                            type: "string",
                            description: "Product stock keeping unit",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "name",
                            label: "Product name",
                            type: "string",
                            description: "Product display name",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "description",
                            label: "Description",
                            type: "text",
                            description: "Product description",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "price",
                            label: "Price",
                            type: "number",
                            description: "Current product price",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "active",
                            label: "Active",
                            type: "boolean",
                            description: "Whether the product is active",
                            required: true,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "address",
                title: "Address",
                category: "Location",
                icon: "📍",
                color: "bg-emerald-50 text-emerald-500",
                description: "Postal or physical address.",
                definition: {
                    fields: [
                        {
                            name: "street",
                            label: "Street",
                            type: "string",
                            description: "Street address",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "city",
                            label: "City",
                            type: "string",
                            description: "City",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "postal_code",
                            label: "Postal code",
                            type: "string",
                            description: "Postal or ZIP code",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "country",
                            label: "Country",
                            type: "string",
                            description: "Country",
                            required: true,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "contact",
                title: "Contact",
                category: "Communication",
                icon: "☎",
                color: "bg-fuchsia-50 text-fuchsia-500",
                description: "Reusable contact information.",
                definition: {
                    fields: [
                        {
                            name: "name",
                            label: "Contact name",
                            type: "string",
                            description: "Contact person",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "email",
                            label: "Email",
                            type: "email",
                            description: "Contact email",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "phone",
                            label: "Phone",
                            type: "string",
                            description: "Contact phone",
                            required: false,
                            multiple: true,
                            active: true
                        },
                        {
                            name: "website",
                            label: "Website",
                            type: "url",
                            description: "Contact website",
                            required: false,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "event",
                title: "Event",
                category: "Activity",
                icon: "📅",
                color: "bg-indigo-50 text-indigo-500",
                description: "Event, appointment or scheduled activity.",
                definition: {
                    fields: [
                        {
                            name: "title",
                            label: "Title",
                            type: "string",
                            description: "Event title",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "description",
                            label: "Description",
                            type: "text",
                            description: "Event description",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "starts_at",
                            label: "Starts at",
                            type: "datetime",
                            description: "Event start",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "ends_at",
                            label: "Ends at",
                            type: "datetime",
                            description: "Event end",
                            required: false,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "article",
                title: "Article",
                category: "Content",
                icon: "📰",
                color: "bg-amber-50 text-amber-500",
                description: "Article, post or editorial content.",
                definition: {
                    fields: [
                        {
                            name: "title",
                            label: "Title",
                            type: "string",
                            description: "Article title",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "slug",
                            label: "Slug",
                            type: "string",
                            description: "URL-friendly identifier",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "body",
                            label: "Body",
                            type: "text",
                            description: "Article content",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "published_at",
                            label: "Published at",
                            type: "datetime",
                            description: "Publication timestamp",
                            required: false,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "order",
                title: "Order",
                category: "Commerce",
                icon: "🛒",
                color: "bg-rose-50 text-rose-500",
                description: "Customer order or transaction.",
                definition: {
                    fields: [
                        {
                            name: "order_number",
                            label: "Order number",
                            type: "string",
                            description: "Human-readable order number",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "customer_id",
                            label: "Customer ID",
                            type: "integer",
                            description: "Customer identifier",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "total",
                            label: "Total",
                            type: "number",
                            description: "Order total",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "paid",
                            label: "Paid",
                            type: "boolean",
                            description: "Payment state",
                            required: true,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "invoice",
                title: "Invoice",
                category: "Finance",
                icon: "🧾",
                color: "bg-lime-50 text-lime-600",
                description: "Invoice or billing document.",
                definition: {
                    fields: [
                        {
                            name: "invoice_number",
                            label: "Invoice number",
                            type: "string",
                            description: "Invoice number",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "customer_name",
                            label: "Customer",
                            type: "string",
                            description: "Customer name",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "amount",
                            label: "Amount",
                            type: "number",
                            description: "Invoice amount",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "issued_at",
                            label: "Issued at",
                            type: "date",
                            description: "Invoice issue date",
                            required: true,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            },

            {
                id: "project",
                title: "Project",
                category: "Management",
                icon: "🚀",
                color: "bg-cyan-50 text-cyan-500",
                description: "Project, initiative or workstream.",
                definition: {
                    fields: [
                        {
                            name: "name",
                            label: "Project name",
                            type: "string",
                            description: "Project name",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "description",
                            label: "Description",
                            type: "text",
                            description: "Project description",
                            required: false,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "status",
                            label: "Status",
                            type: "string",
                            description: "Current project status",
                            required: true,
                            multiple: false,
                            active: true
                        },
                        {
                            name: "start_date",
                            label: "Start date",
                            type: "date",
                            description: "Project start",
                            required: false,
                            multiple: false,
                            active: true
                        }
                    ]
                }
            }
        ]
    }
}