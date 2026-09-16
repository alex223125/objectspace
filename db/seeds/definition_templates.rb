DEFINITION_LIBRARY = [
  {
    id: "customer",
    name: "Customer",
    category: "CRM",
    description: "A commercial customer or account contact.",
    icon: "◉",
    color: "violet",
    featured: true,
    new: false,
    tags: %w[
      crm
      customer
      sales
      contact
    ],
    fields: [
      {
        id: "first_name",
        name: "First Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "last_name",
        name: "Last Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "email",
        name: "Email",
        type: "email",
        required: true,
        active: true
      },
      {
        id: "phone",
        name: "Phone",
        type: "phone",
        required: false,
        active: true
      },
      {
        id: "company",
        name: "Company",
        type: "text",
        required: false,
        active: true
      },
      {
        id: "status",
        name: "Status",
        type: "select",
        required: true,
        active: true,
        options: %w[
          lead
          active
          inactive
          archived
        ]
      }
    ]
  },

  {
    id: "company",
    name: "Company",
    category: "CRM",
    description: "A business organization, account, or corporate customer.",
    icon: "▣",
    color: "blue",
    featured: true,
    tags: %w[
      crm
      company
      account
      b2b
    ],
    fields: [
      {
        id: "name",
        name: "Company Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "website",
        name: "Website",
        type: "url",
        required: false,
        active: true
      },
      {
        id: "industry",
        name: "Industry",
        type: "select",
        required: false,
        active: true
      },
      {
        id: "employee_count",
        name: "Employee Count",
        type: "number",
        required: false,
        active: true
      },
      {
        id: "annual_revenue",
        name: "Annual Revenue",
        type: "currency",
        required: false,
        active: true
      },
      {
        id: "status",
        name: "Status",
        type: "select",
        required: true,
        active: true
      }
    ]
  },

  {
    id: "lead",
    name: "Lead",
    category: "CRM",
    description: "A potential customer or sales prospect.",
    icon: "✦",
    color: "orange",
    featured: true,
    tags: %w[
      crm
      sales
      prospect
      pipeline
    ],
    fields: [
      {
        id: "name",
        name: "Lead Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "email",
        name: "Email",
        type: "email",
        required: true,
        active: true
      },
      {
        id: "phone",
        name: "Phone",
        type: "phone",
        required: false,
        active: true
      },
      {
        id: "source",
        name: "Lead Source",
        type: "select",
        required: false,
        active: true
      },
      {
        id: "score",
        name: "Lead Score",
        type: "number",
        required: false,
        active: true
      },
      {
        id: "status",
        name: "Status",
        type: "select",
        required: true,
        active: true
      }
    ]
  },

  {
    id: "contact",
    name: "Contact",
    category: "CRM",
    description: "A person or business contact record.",
    icon: "◎",
    color: "sky",
    tags: %w[
      crm
      contact
      communication
    ],
    fields: [
      {
        id: "name",
        name: "Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "email",
        name: "Email",
        type: "email",
        required: false,
        active: true
      },
      {
        id: "phone",
        name: "Phone",
        type: "phone",
        required: false,
        active: true
      },
      {
        id: "job_title",
        name: "Job Title",
        type: "text",
        required: false,
        active: true
      }
    ]
  },

  {
    id: "deal",
    name: "Deal",
    category: "Sales",
    description: "A sales opportunity moving through a commercial pipeline.",
    icon: "◇",
    color: "emerald",
    featured: true,
    tags: %w[
      sales
      opportunity
      pipeline
      revenue
    ],
    fields: [
      {
        id: "name",
        name: "Deal Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "value",
        name: "Deal Value",
        type: "currency",
        required: true,
        active: true
      },
      {
        id: "stage",
        name: "Sales Stage",
        type: "select",
        required: true,
        active: true
      },
      {
        id: "close_date",
        name: "Expected Close Date",
        type: "date",
        required: false,
        active: true
      },
      {
        id: "probability",
        name: "Probability",
        type: "number",
        required: false,
        active: true
      }
    ]
  },

  {
    id: "product",
    name: "Product",
    category: "Commerce",
    description: "A product or sellable item.",
    icon: "□",
    color: "violet",
    featured: true,
    tags: %w[
      commerce
      product
      catalog
      inventory
    ],
    fields: [
      {
        id: "name",
        name: "Product Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "sku",
        name: "SKU",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "price",
        name: "Price",
        type: "currency",
        required: true,
        active: true
      },
      {
        id: "category",
        name: "Category",
        type: "select",
        required: false,
        active: true
      },
      {
        id: "description",
        name: "Description",
        type: "textarea",
        required: false,
        active: true
      },
      {
        id: "active",
        name: "Active",
        type: "boolean",
        required: true,
        active: true
      }
    ]
  },

  {
    id: "order",
    name: "Order",
    category: "Commerce",
    description: "A customer purchase or commercial order.",
    icon: "▤",
    color: "blue",
    tags: %w[
      commerce
      order
      ecommerce
      transaction
    ],
    fields: [
      {
        id: "order_number",
        name: "Order Number",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "customer",
        name: "Customer",
        type: "relation",
        required: true,
        active: true
      },
      {
        id: "total",
        name: "Total",
        type: "currency",
        required: true,
        active: true
      },
      {
        id: "status",
        name: "Order Status",
        type: "select",
        required: true,
        active: true
      },
      {
        id: "ordered_at",
        name: "Ordered At",
        type: "datetime",
        required: true,
        active: true
      }
    ]
  },

  {
    id: "invoice",
    name: "Invoice",
    category: "Finance",
    description: "A commercial invoice issued to a customer.",
    icon: "▥",
    color: "emerald",
    featured: true,
    tags: %w[
      finance
      invoice
      billing
      accounting
    ],
    fields: [
      {
        id: "invoice_number",
        name: "Invoice Number",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "customer",
        name: "Customer",
        type: "relation",
        required: true,
        active: true
      },
      {
        id: "issue_date",
        name: "Issue Date",
        type: "date",
        required: true,
        active: true
      },
      {
        id: "due_date",
        name: "Due Date",
        type: "date",
        required: true,
        active: true
      },
      {
        id: "amount",
        name: "Amount",
        type: "currency",
        required: true,
        active: true
      },
      {
        id: "status",
        name: "Status",
        type: "select",
        required: true,
        active: true
      }
    ]
  },

  {
    id: "employee",
    name: "Employee",
    category: "HR",
    description: "An employee or internal team member.",
    icon: "♙",
    color: "sky",
    featured: true,
    tags: %w[
      hr
      employee
      people
      workforce
    ],
    fields: [
      {
        id: "first_name",
        name: "First Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "last_name",
        name: "Last Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "email",
        name: "Work Email",
        type: "email",
        required: true,
        active: true
      },
      {
        id: "department",
        name: "Department",
        type: "select",
        required: true,
        active: true
      },
      {
        id: "job_title",
        name: "Job Title",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "start_date",
        name: "Start Date",
        type: "date",
        required: false,
        active: true
      }
    ]
  },

  {
    id: "project",
    name: "Project",
    category: "Operations",
    description: "A project, initiative, or delivery engagement.",
    icon: "◈",
    color: "violet",
    featured: true,
    tags: %w[
      operations
      project
      delivery
      management
    ],
    fields: [
      {
        id: "name",
        name: "Project Name",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "owner",
        name: "Owner",
        type: "relation",
        required: true,
        active: true
      },
      {
        id: "status",
        name: "Status",
        type: "select",
        required: true,
        active: true
      },
      {
        id: "start_date",
        name: "Start Date",
        type: "date",
        required: false,
        active: true
      },
      {
        id: "end_date",
        name: "End Date",
        type: "date",
        required: false,
        active: true
      }
    ]
  },

  {
    id: "ticket",
    name: "Support Ticket",
    category: "Support",
    description: "A customer support request or service issue.",
    icon: "◌",
    color: "orange",
    featured: true,
    tags: %w[
      support
      customer
      ticket
      service
    ],
    fields: [
      {
        id: "subject",
        name: "Subject",
        type: "text",
        required: true,
        active: true
      },
      {
        id: "customer",
        name: "Customer",
        type: "relation",
        required: true,
        active: true
      },
      {
        id: "priority",
        name: "Priority",
        type: "select",
        required: true,
        active: true
      },
      {
        id: "status",
        name: "Status",
        type: "select",
        required: true,
        active: true
      },
      {
        id: "description",
        name: "Description",
        type: "textarea",
        required: false,
        active: true
      }
    ]
  }
].freeze