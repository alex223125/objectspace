const definitionLibraryCatalog = [
    {
        id: "organization",
        title: "Organization",
        category: "Business",
        icon: "🏢",
        color: "sky",
        description: "Company, institution or organization.",
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
    },

    {
        id: "product",
        title: "Product",
        category: "Commerce",
        icon: "📦",
        color: "orange",
        description: "Product or catalog item.",
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
    },

    {
        id: "address",
        title: "Address",
        category: "Location",
        icon: "📍",
        color: "emerald",
        description: "Postal or physical address.",
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
    },

    {
        id: "contact",
        title: "Contact",
        category: "Communication",
        icon: "☎",
        color: "fuchsia",
        description: "Reusable contact information.",
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
    },

    {
        id: "event",
        title: "Event",
        category: "Activity",
        icon: "📅",
        color: "indigo",
        description: "Event, appointment or scheduled activity.",
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
    },

    {
        id: "article",
        title: "Article",
        category: "Content",
        icon: "📰",
        color: "amber",
        description: "Article, post or editorial content.",
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
    },

    {
        id: "order",
        title: "Order",
        category: "Commerce",
        icon: "🛒",
        color: "rose",
        description: "Customer order or transaction.",
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
    },

    {
        id: "invoice",
        title: "Invoice",
        category: "Finance",
        icon: "🧾",
        color: "lime",
        description: "Invoice or billing document.",
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
    },

    {
        id: "project",
        title: "Project",
        category: "Management",
        icon: "🚀",
        color: "cyan",
        description: "Project, initiative or workstream.",
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
]

export default definitionLibraryCatalog