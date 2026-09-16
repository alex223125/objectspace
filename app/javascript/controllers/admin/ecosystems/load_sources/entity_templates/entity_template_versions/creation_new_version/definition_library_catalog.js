// app/javascript/controllers/definition_library_catalog.js

/*
 * Definition Library Catalog
 * --------------------------
 *
 * Commercial-ready seed catalog for the Definition Library.
 *
 * Designed for:
 *   - Stimulus
 *   - Rails
 *   - Definition Studio
 *   - Search
 *   - Category filtering
 *   - Tag filtering
 *   - Sorting
 *   - Preview
 *   - JSON export
 *   - Future API replacement
 *
 * IMPORTANT:
 * Keep this structure stable.
 *
 * The catalog can later be loaded from:
 *
 *   GET /admin/definition-library/catalog.json
 *
 * without changing the UI contract.
 */

const field = (
    name,
    type,
    {
        label = null,
        required = false,
        active = true,
        description = "",
        defaultValue = null,
        options = [],
        searchable = false,
        sortable = false,
        unique = false,
        system = false,
    } = {}
) => ({
    name,
    label: label || humanize(name),
    type,
    required,
    active,
    description,
    defaultValue,
    options,
    searchable,
    sortable,
    unique,
    system,
});

function humanize(value) {
    return String(value)
        .replace(/[_-]+/g, " ")
        .replace(/\b\w/g, (character) => character.toUpperCase());
}

const definition = ({
                        id,
                        name,
                        category,
                        icon = "✦",
                        description,
                        tags = [],
                        fields = [],
                        popularity = 50,
                        featured = false,
                        isNew = false,
                        version = "1.0.0",
                        status = "active",
                    }) => ({
    id,
    name,
    category,
    icon,
    description,
    tags,
    fields,
    popularity,
    featured,
    new: isNew,
    version,
    status,
    createdAt: isNew ? "2026-09-01" : "2026-01-15",
    updatedAt: "2026-09-15",
});

export const DEFINITION_LIBRARY_CATALOG = [

    // ============================================================
    // 01 — CUSTOMER & CRM
    // ============================================================

    definition({
        id: "customer-profile",
        name: "Customer Profile",
        category: "CUSTOMER & CRM",
        icon: "👤",
        description:
            "Core customer record for B2B and B2C customer management, segmentation and relationship workflows.",
        tags: ["customer", "crm", "account", "contact", "profile"],
        popularity: 99,
        featured: true,
        fields: [
            field("customer_id", "string", {
                required: true,
                unique: true,
                searchable: true,
                sortable: true,
                description: "Stable unique identifier for the customer.",
            }),
            field("first_name", "string", {
                required: true,
                searchable: true,
                description: "Customer first name.",
            }),
            field("last_name", "string", {
                required: true,
                searchable: true,
                description: "Customer last name.",
            }),
            field("email", "email", {
                required: true,
                unique: true,
                searchable: true,
                description: "Primary customer email address.",
            }),
            field("phone", "phone", {
                searchable: true,
                description: "Primary customer phone number.",
            }),
            field("customer_type", "select", {
                required: true,
                options: ["individual", "business", "partner"],
                description: "Commercial classification of the customer.",
            }),
            field("status", "select", {
                required: true,
                options: ["active", "inactive", "prospect", "blocked"],
                description: "Current customer lifecycle status.",
            }),
            field("lifetime_value", "currency", {
                description: "Estimated total commercial value of the customer.",
                sortable: true,
            }),
            field("created_at", "datetime", {
                system: true,
                sortable: true,
                description: "Timestamp when the customer record was created.",
            }),
        ],
    }),

    definition({
        id: "contact-person",
        name: "Contact Person",
        category: "CUSTOMER & CRM",
        icon: "☎",
        description:
            "Business or organizational contact used for communication, sales and account management.",
        tags: ["contact", "crm", "person", "sales"],
        popularity: 94,
        featured: true,
        fields: [
            field("contact_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("first_name", "string", {
                required: true,
                searchable: true,
            }),
            field("last_name", "string", {
                required: true,
                searchable: true,
            }),
            field("job_title", "string", {
                searchable: true,
            }),
            field("email", "email", {
                required: true,
                searchable: true,
            }),
            field("phone", "phone"),
            field("department", "string", {
                searchable: true,
            }),
            field("preferred_contact_method", "select", {
                options: ["email", "phone", "sms", "other"],
            }),
            field("status", "select", {
                required: true,
                options: ["active", "inactive"],
            }),
        ],
    }),

    definition({
        id: "company-account",
        name: "Company Account",
        category: "CUSTOMER & CRM",
        icon: "🏢",
        description:
            "Organization-level account structure for B2B sales, customer success and account management.",
        tags: ["company", "account", "b2b", "organization", "crm"],
        popularity: 97,
        featured: true,
        fields: [
            field("account_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("company_name", "string", {
                required: true,
                searchable: true,
                sortable: true,
            }),
            field("legal_name", "string", {
                searchable: true,
            }),
            field("industry", "select", {
                options: [
                    "technology",
                    "finance",
                    "healthcare",
                    "retail",
                    "manufacturing",
                    "professional_services",
                    "other",
                ],
            }),
            field("website", "url"),
            field("employee_count", "integer", {
                sortable: true,
            }),
            field("annual_revenue", "currency", {
                sortable: true,
            }),
            field("account_status", "select", {
                required: true,
                options: ["prospect", "customer", "inactive", "churned"],
            }),
            field("owner_id", "string", {
                searchable: true,
            }),
        ],
    }),

    definition({
        id: "lead",
        name: "Sales Lead",
        category: "CUSTOMER & CRM",
        icon: "🎯",
        description:
            "Qualified or unqualified sales opportunity entering the commercial pipeline.",
        tags: ["lead", "sales", "crm", "prospect", "pipeline"],
        popularity: 96,
        fields: [
            field("lead_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("company_name", "string", {
                searchable: true,
            }),
            field("contact_name", "string", {
                required: true,
                searchable: true,
            }),
            field("email", "email", {
                required: true,
                searchable: true,
            }),
            field("source", "select", {
                options: [
                    "website",
                    "referral",
                    "advertising",
                    "event",
                    "partner",
                    "outbound",
                    "other",
                ],
            }),
            field("lead_score", "integer", {
                sortable: true,
            }),
            field("stage", "select", {
                required: true,
                options: [
                    "new",
                    "contacted",
                    "qualified",
                    "proposal",
                    "won",
                    "lost",
                ],
            }),
            field("estimated_value", "currency", {
                sortable: true,
            }),
            field("created_at", "datetime", {
                system: true,
                sortable: true,
            }),
        ],
    }),

    definition({
        id: "customer-interaction",
        name: "Customer Interaction",
        category: "CUSTOMER & CRM",
        icon: "💬",
        description:
            "Timeline event representing an interaction between your organization and a customer.",
        tags: ["interaction", "activity", "crm", "communication"],
        popularity: 88,
        fields: [
            field("interaction_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string", {
                required: true,
                searchable: true,
            }),
            field("interaction_type", "select", {
                required: true,
                options: ["call", "email", "meeting", "chat", "note", "other"],
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("performed_by", "string", {
                searchable: true,
            }),
            field("occurred_at", "datetime", {
                required: true,
                sortable: true,
            }),
        ],
    }),

    // ============================================================
    // 02 — SALES
    // ============================================================

    definition({
        id: "sales-opportunity",
        name: "Sales Opportunity",
        category: "SALES",
        icon: "💼",
        description:
            "Commercial opportunity used to manage potential revenue through a structured sales pipeline.",
        tags: ["sales", "opportunity", "pipeline", "revenue", "crm"],
        popularity: 98,
        featured: true,
        fields: [
            field("opportunity_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("account_id", "string", {
                required: true,
                searchable: true,
            }),
            field("owner_id", "string", {
                required: true,
            }),
            field("stage", "select", {
                required: true,
                options: [
                    "discovery",
                    "qualification",
                    "proposal",
                    "negotiation",
                    "closed_won",
                    "closed_lost",
                ],
            }),
            field("amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("probability", "percentage", {
                sortable: true,
            }),
            field("expected_close_date", "date", {
                sortable: true,
            }),
            field("created_at", "datetime", {
                system: true,
            }),
        ],
    }),

    definition({
        id: "sales-quote",
        name: "Sales Quote",
        category: "SALES",
        icon: "🧾",
        description:
            "Commercial quotation containing pricing, validity and customer-facing sales terms.",
        tags: ["quote", "quotation", "sales", "pricing"],
        popularity: 91,
        fields: [
            field("quote_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("quote_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("issue_date", "date", {
                required: true,
            }),
            field("expiry_date", "date"),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("subtotal", "currency", {
                required: true,
            }),
            field("tax_total", "currency"),
            field("grand_total", "currency", {
                required: true,
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["draft", "sent", "accepted", "rejected", "expired"],
            }),
        ],
    }),

    definition({
        id: "sales-order",
        name: "Sales Order",
        category: "SALES",
        icon: "🛒",
        description:
            "Confirmed customer order representing a commercial commitment to supply products or services.",
        tags: ["order", "sales", "commerce", "customer"],
        popularity: 95,
        featured: true,
        fields: [
            field("order_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("order_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("order_date", "date", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("subtotal", "currency", {
                required: true,
            }),
            field("tax_total", "currency"),
            field("discount_total", "currency"),
            field("grand_total", "currency", {
                required: true,
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: [
                    "pending",
                    "confirmed",
                    "processing",
                    "fulfilled",
                    "cancelled",
                ],
            }),
        ],
    }),

    definition({
        id: "sales-activity",
        name: "Sales Activity",
        category: "SALES",
        icon: "📈",
        description:
            "Trackable sales action such as a call, meeting, demo, follow-up or task.",
        tags: ["sales", "activity", "task", "crm"],
        popularity: 84,
        fields: [
            field("activity_id", "string", {
                required: true,
                unique: true,
            }),
            field("activity_type", "select", {
                required: true,
                options: ["call", "meeting", "demo", "email", "task", "follow_up"],
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("owner_id", "string", {
                required: true,
            }),
            field("related_account_id", "string"),
            field("due_at", "datetime", {
                sortable: true,
            }),
            field("completed_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["open", "completed", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 03 — FINANCE
    // ============================================================

    definition({
        id: "invoice",
        name: "Invoice",
        category: "FINANCE",
        icon: "💶",
        description:
            "Customer invoice for billing, accounting, payment tracking and financial reporting.",
        tags: ["invoice", "billing", "finance", "accounting", "payment"],
        popularity: 100,
        featured: true,
        fields: [
            field("invoice_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("invoice_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("issue_date", "date", {
                required: true,
                sortable: true,
            }),
            field("due_date", "date", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("subtotal", "currency", {
                required: true,
            }),
            field("tax_total", "currency"),
            field("total", "currency", {
                required: true,
                sortable: true,
            }),
            field("amount_paid", "currency"),
            field("status", "select", {
                required: true,
                options: ["draft", "issued", "partially_paid", "paid", "overdue", "void"],
            }),
        ],
    }),

    definition({
        id: "payment",
        name: "Payment",
        category: "FINANCE",
        icon: "💳",
        description:
            "Recorded financial payment associated with an invoice, order or customer account.",
        tags: ["payment", "finance", "transaction", "billing"],
        popularity: 97,
        fields: [
            field("payment_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("invoice_id", "string"),
            field("amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("payment_method", "select", {
                required: true,
                options: ["card", "bank_transfer", "cash", "direct_debit", "other"],
            }),
            field("transaction_reference", "string", {
                searchable: true,
            }),
            field("paid_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["pending", "completed", "failed", "refunded"],
            }),
        ],
    }),

    definition({
        id: "expense",
        name: "Business Expense",
        category: "FINANCE",
        icon: "💸",
        description:
            "Business expense record for accounting, reimbursement and financial reporting.",
        tags: ["expense", "finance", "accounting", "reimbursement"],
        popularity: 89,
        fields: [
            field("expense_id", "string", {
                required: true,
                unique: true,
            }),
            field("employee_id", "string", {
                required: true,
            }),
            field("expense_date", "date", {
                required: true,
                sortable: true,
            }),
            field("category", "select", {
                required: true,
                options: [
                    "travel",
                    "meals",
                    "software",
                    "office",
                    "marketing",
                    "equipment",
                    "other",
                ],
            }),
            field("merchant", "string", {
                searchable: true,
            }),
            field("amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("receipt_url", "url"),
            field("status", "select", {
                required: true,
                options: ["draft", "submitted", "approved", "rejected", "reimbursed"],
            }),
        ],
    }),

    definition({
        id: "subscription",
        name: "Subscription",
        category: "FINANCE",
        icon: "🔁",
        description:
            "Recurring commercial subscription used for SaaS, memberships and recurring billing.",
        tags: ["subscription", "recurring", "billing", "saas", "finance"],
        popularity: 99,
        featured: true,
        fields: [
            field("subscription_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("plan_id", "string", {
                required: true,
            }),
            field("billing_interval", "select", {
                required: true,
                options: ["weekly", "monthly", "quarterly", "yearly"],
            }),
            field("price", "currency", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("next_billing_date", "date", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["trial", "active", "paused", "cancelled", "expired"],
            }),
        ],
    }),

    definition({
        id: "budget",
        name: "Budget",
        category: "FINANCE",
        icon: "📊",
        description:
            "Financial budget used to plan and monitor spending or revenue against targets.",
        tags: ["budget", "finance", "planning", "forecast"],
        popularity: 82,
        fields: [
            field("budget_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("fiscal_year", "integer", {
                required: true,
                sortable: true,
            }),
            field("department", "string", {
                searchable: true,
            }),
            field("budget_amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("actual_amount", "currency", {
                sortable: true,
            }),
            field("variance", "currency", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["draft", "approved", "active", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 04 — PRODUCTS & INVENTORY
    // ============================================================

    definition({
        id: "product",
        name: "Product",
        category: "PRODUCTS & INVENTORY",
        icon: "📦",
        description:
            "Core product definition for catalogs, commerce, inventory and product management.",
        tags: ["product", "catalog", "inventory", "commerce"],
        popularity: 100,
        featured: true,
        fields: [
            field("product_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("sku", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
                sortable: true,
            }),
            field("description", "rich_text"),
            field("category_id", "string", {
                searchable: true,
            }),
            field("price", "currency", {
                required: true,
                sortable: true,
            }),
            field("cost", "currency"),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "archived"],
            }),
            field("is_taxable", "boolean", {
                defaultValue: true,
            }),
        ],
    }),

    definition({
        id: "product-variant",
        name: "Product Variant",
        category: "PRODUCTS & INVENTORY",
        icon: "🎨",
        description:
            "Sellable product variation such as size, color, configuration or packaging.",
        tags: ["product", "variant", "sku", "catalog", "commerce"],
        popularity: 90,
        fields: [
            field("variant_id", "string", {
                required: true,
                unique: true,
            }),
            field("product_id", "string", {
                required: true,
            }),
            field("sku", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("attributes", "json"),
            field("price", "currency", {
                required: true,
                sortable: true,
            }),
            field("barcode", "string", {
                searchable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["active", "inactive", "discontinued"],
            }),
        ],
    }),

    definition({
        id: "inventory-item",
        name: "Inventory Item",
        category: "PRODUCTS & INVENTORY",
        icon: "🏷",
        description:
            "Trackable inventory record representing available, reserved or committed stock.",
        tags: ["inventory", "stock", "warehouse", "product"],
        popularity: 93,
        fields: [
            field("inventory_id", "string", {
                required: true,
                unique: true,
            }),
            field("product_id", "string", {
                required: true,
            }),
            field("warehouse_id", "string", {
                required: true,
            }),
            field("quantity_on_hand", "integer", {
                required: true,
                sortable: true,
            }),
            field("quantity_reserved", "integer", {
                sortable: true,
            }),
            field("quantity_available", "integer", {
                sortable: true,
            }),
            field("reorder_level", "integer"),
            field("status", "select", {
                required: true,
                options: ["in_stock", "low_stock", "out_of_stock", "discontinued"],
            }),
        ],
    }),

    definition({
        id: "warehouse",
        name: "Warehouse",
        category: "PRODUCTS & INVENTORY",
        icon: "🏭",
        description:
            "Physical or logical inventory location used for stock management and fulfillment.",
        tags: ["warehouse", "inventory", "logistics", "location"],
        popularity: 78,
        fields: [
            field("warehouse_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("code", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("address", "address"),
            field("country", "string", {
                searchable: true,
            }),
            field("manager_id", "string"),
            field("status", "select", {
                required: true,
                options: ["active", "inactive"],
            }),
        ],
    }),

    // ============================================================
    // 05 — OPERATIONS
    // ============================================================

    definition({
        id: "project",
        name: "Project",
        category: "OPERATIONS",
        icon: "📋",
        description:
            "Project structure for managing work, milestones, ownership, budgets and delivery status.",
        tags: ["project", "operations", "management", "delivery"],
        popularity: 96,
        featured: true,
        fields: [
            field("project_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("project_manager_id", "string", {
                required: true,
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("target_end_date", "date"),
            field("budget", "currency", {
                sortable: true,
            }),
            field("priority", "select", {
                options: ["low", "medium", "high", "critical"],
            }),
            field("status", "select", {
                required: true,
                options: ["planned", "active", "on_hold", "completed", "cancelled"],
            }),
        ],
    }),

    definition({
        id: "task",
        name: "Task",
        category: "OPERATIONS",
        icon: "✓",
        description:
            "Actionable work item assigned to an individual or team with status and due date.",
        tags: ["task", "work", "operations", "project", "productivity"],
        popularity: 98,
        featured: true,
        fields: [
            field("task_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("assignee_id", "string", {
                searchable: true,
            }),
            field("project_id", "string"),
            field("priority", "select", {
                required: true,
                options: ["low", "medium", "high", "urgent"],
            }),
            field("due_date", "date", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["todo", "in_progress", "blocked", "done", "cancelled"],
            }),
        ],
    }),

    definition({
        id: "workflow",
        name: "Workflow",
        category: "OPERATIONS",
        icon: "⚙",
        description:
            "Configurable business workflow containing stages, ownership and automation rules.",
        tags: ["workflow", "automation", "operations", "process"],
        popularity: 92,
        fields: [
            field("workflow_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("trigger_type", "select", {
                required: true,
                options: ["manual", "event", "schedule", "api"],
            }),
            field("owner_id", "string"),
            field("steps", "json", {
                required: true,
            }),
            field("enabled", "boolean", {
                required: true,
                defaultValue: true,
            }),
            field("last_run_at", "datetime"),
        ],
    }),

    definition({
        id: "service-request",
        name: "Service Request",
        category: "OPERATIONS",
        icon: "🛠",
        description:
            "Operational request submitted by a customer, employee or business stakeholder.",
        tags: ["service", "request", "support", "operations"],
        popularity: 91,
        fields: [
            field("request_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("requester_id", "string", {
                required: true,
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("request_type", "select", {
                required: true,
                options: ["service", "information", "change", "incident", "other"],
            }),
            field("priority", "select", {
                required: true,
                options: ["low", "medium", "high", "critical"],
            }),
            field("assigned_to", "string"),
            field("status", "select", {
                required: true,
                options: ["new", "assigned", "in_progress", "resolved", "closed"],
            }),
        ],
    }),

    definition({
        id: "approval-request",
        name: "Approval Request",
        category: "OPERATIONS",
        icon: "✓",
        description:
            "Structured request requiring review and approval before a business action proceeds.",
        tags: ["approval", "workflow", "governance", "operations"],
        popularity: 87,
        fields: [
            field("approval_id", "string", {
                required: true,
                unique: true,
            }),
            field("request_type", "string", {
                required: true,
                searchable: true,
            }),
            field("requester_id", "string", {
                required: true,
            }),
            field("approver_id", "string", {
                required: true,
            }),
            field("amount", "currency"),
            field("reason", "text", {
                required: true,
            }),
            field("decision", "select", {
                options: ["pending", "approved", "rejected"],
            }),
            field("decided_at", "datetime"),
        ],
    }),

    // ============================================================
    // 06 — HUMAN RESOURCES
    // ============================================================

    definition({
        id: "employee",
        name: "Employee",
        category: "HUMAN RESOURCES",
        icon: "👥",
        description:
            "Core employee profile for workforce management, HR operations and organizational records.",
        tags: ["employee", "hr", "people", "workforce"],
        popularity: 98,
        featured: true,
        fields: [
            field("employee_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("first_name", "string", {
                required: true,
                searchable: true,
            }),
            field("last_name", "string", {
                required: true,
                searchable: true,
            }),
            field("work_email", "email", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("job_title", "string", {
                required: true,
                searchable: true,
            }),
            field("department", "string", {
                searchable: true,
            }),
            field("manager_id", "string"),
            field("hire_date", "date", {
                required: true,
                sortable: true,
            }),
            field("employment_status", "select", {
                required: true,
                options: ["active", "leave", "terminated", "contractor"],
            }),
        ],
    }),

    definition({
        id: "job-position",
        name: "Job Position",
        category: "HUMAN RESOURCES",
        icon: "💼",
        description:
            "Organizational position defining responsibilities, department, compensation range and hiring status.",
        tags: ["job", "position", "recruitment", "hr"],
        popularity: 86,
        fields: [
            field("position_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("department", "string", {
                required: true,
                searchable: true,
            }),
            field("location", "string", {
                searchable: true,
            }),
            field("employment_type", "select", {
                required: true,
                options: ["full_time", "part_time", "contract", "internship"],
            }),
            field("salary_min", "currency"),
            field("salary_max", "currency"),
            field("description", "rich_text"),
            field("status", "select", {
                required: true,
                options: ["draft", "open", "paused", "filled", "closed"],
            }),
        ],
    }),

    definition({
        id: "candidate",
        name: "Recruitment Candidate",
        category: "HUMAN RESOURCES",
        icon: "🧑‍💼",
        description:
            "Candidate profile for recruitment pipelines, interviews and hiring decisions.",
        tags: ["candidate", "recruitment", "hiring", "hr"],
        popularity: 85,
        fields: [
            field("candidate_id", "string", {
                required: true,
                unique: true,
            }),
            field("first_name", "string", {
                required: true,
                searchable: true,
            }),
            field("last_name", "string", {
                required: true,
                searchable: true,
            }),
            field("email", "email", {
                required: true,
                searchable: true,
            }),
            field("phone", "phone"),
            field("resume_url", "url"),
            field("source", "select", {
                options: ["career_site", "referral", "agency", "linkedin", "other"],
            }),
            field("stage", "select", {
                required: true,
                options: [
                    "new",
                    "screening",
                    "interview",
                    "offer",
                    "hired",
                    "rejected",
                ],
            }),
        ],
    }),

    definition({
        id: "leave-request",
        name: "Leave Request",
        category: "HUMAN RESOURCES",
        icon: "🌴",
        description:
            "Employee leave request used for vacation, absence and approval workflows.",
        tags: ["leave", "absence", "vacation", "hr"],
        popularity: 79,
        fields: [
            field("leave_request_id", "string", {
                required: true,
                unique: true,
            }),
            field("employee_id", "string", {
                required: true,
            }),
            field("leave_type", "select", {
                required: true,
                options: ["vacation", "sick", "parental", "personal", "other"],
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("end_date", "date", {
                required: true,
            }),
            field("days_requested", "number", {
                required: true,
            }),
            field("reason", "text"),
            field("status", "select", {
                required: true,
                options: ["pending", "approved", "rejected", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 07 — SUPPORT
    // ============================================================

    definition({
        id: "support-ticket",
        name: "Support Ticket",
        category: "SUPPORT",
        icon: "🎫",
        description:
            "Customer support case for tracking issues, requests, ownership, priority and resolution.",
        tags: ["support", "ticket", "customer-service", "helpdesk"],
        popularity: 100,
        featured: true,
        fields: [
            field("ticket_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("ticket_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "rich_text", {
                required: true,
            }),
            field("priority", "select", {
                required: true,
                options: ["low", "medium", "high", "urgent"],
            }),
            field("assigned_agent_id", "string"),
            field("category", "string", {
                searchable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["new", "open", "pending", "resolved", "closed"],
            }),
            field("created_at", "datetime", {
                system: true,
                sortable: true,
            }),
        ],
    }),

    definition({
        id: "support-article",
        name: "Knowledge Base Article",
        category: "SUPPORT",
        icon: "📚",
        description:
            "Reusable support and knowledge article for customer self-service and internal documentation.",
        tags: ["knowledge", "support", "documentation", "help-center"],
        popularity: 83,
        fields: [
            field("article_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("slug", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("content", "rich_text", {
                required: true,
            }),
            field("category", "string", {
                searchable: true,
            }),
            field("author_id", "string"),
            field("published_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "published", "archived"],
            }),
        ],
    }),

    // ============================================================
    // 08 — MARKETING
    // ============================================================

    definition({
        id: "marketing-campaign",
        name: "Marketing Campaign",
        category: "MARKETING",
        icon: "📣",
        description:
            "Campaign structure for coordinating marketing activities, audiences, budgets and performance.",
        tags: ["marketing", "campaign", "advertising", "growth"],
        popularity: 94,
        featured: true,
        fields: [
            field("campaign_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("campaign_type", "select", {
                required: true,
                options: ["email", "paid", "social", "event", "content", "other"],
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("end_date", "date"),
            field("budget", "currency", {
                sortable: true,
            }),
            field("target_audience", "string", {
                searchable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["draft", "scheduled", "active", "paused", "completed"],
            }),
        ],
    }),

    definition({
        id: "marketing-contact",
        name: "Marketing Contact",
        category: "MARKETING",
        icon: "📇",
        description:
            "Marketing audience contact used for segmentation, consent and campaign communication.",
        tags: ["marketing", "contact", "audience", "email"],
        popularity: 90,
        fields: [
            field("contact_id", "string", {
                required: true,
                unique: true,
            }),
            field("email", "email", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("first_name", "string", {
                searchable: true,
            }),
            field("last_name", "string", {
                searchable: true,
            }),
            field("company", "string", {
                searchable: true,
            }),
            field("segment", "string", {
                searchable: true,
            }),
            field("marketing_consent", "boolean", {
                required: true,
            }),
            field("status", "select", {
                required: true,
                options: ["subscribed", "unsubscribed", "suppressed"],
            }),
        ],
    }),

    definition({
        id: "email-campaign",
        name: "Email Campaign",
        category: "MARKETING",
        icon: "✉",
        description:
            "Email marketing campaign containing message content, audience and delivery configuration.",
        tags: ["email", "campaign", "marketing", "newsletter"],
        popularity: 88,
        fields: [
            field("campaign_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("from_email", "email", {
                required: true,
            }),
            field("audience_id", "string", {
                required: true,
            }),
            field("content", "rich_text", {
                required: true,
            }),
            field("scheduled_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "scheduled", "sending", "sent", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 09 — E-COMMERCE
    // ============================================================

    definition({
        id: "shopping-cart",
        name: "Shopping Cart",
        category: "E-COMMERCE",
        icon: "🛍",
        description:
            "Customer shopping cart containing products, quantities, discounts and totals.",
        tags: ["cart", "ecommerce", "checkout", "commerce"],
        popularity: 93,
        fields: [
            field("cart_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string"),
            field("session_id", "string"),
            field("items", "json", {
                required: true,
            }),
            field("subtotal", "currency", {
                required: true,
            }),
            field("discount_total", "currency"),
            field("tax_total", "currency"),
            field("total", "currency", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("updated_at", "datetime", {
                sortable: true,
            }),
        ],
    }),

    definition({
        id: "checkout",
        name: "Checkout",
        category: "E-COMMERCE",
        icon: "🧾",
        description:
            "Checkout transaction containing customer, delivery, payment and order preparation details.",
        tags: ["checkout", "ecommerce", "payment", "order"],
        popularity: 95,
        featured: true,
        fields: [
            field("checkout_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("cart_id", "string", {
                required: true,
            }),
            field("billing_address", "address", {
                required: true,
            }),
            field("shipping_address", "address"),
            field("payment_method", "select", {
                required: true,
                options: ["card", "paypal", "bank_transfer", "other"],
            }),
            field("subtotal", "currency", {
                required: true,
            }),
            field("shipping_total", "currency"),
            field("tax_total", "currency"),
            field("grand_total", "currency", {
                required: true,
            }),
            field("status", "select", {
                required: true,
                options: ["started", "payment_pending", "completed", "failed", "expired"],
            }),
        ],
    }),

    definition({
        id: "discount",
        name: "Discount",
        category: "E-COMMERCE",
        icon: "🏷",
        description:
            "Promotional discount rule used to reduce product, order or subscription pricing.",
        tags: ["discount", "promotion", "coupon", "commerce"],
        popularity: 89,
        fields: [
            field("discount_id", "string", {
                required: true,
                unique: true,
            }),
            field("code", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("description", "text"),
            field("discount_type", "select", {
                required: true,
                options: ["percentage", "fixed_amount", "free_shipping"],
            }),
            field("discount_value", "number", {
                required: true,
                sortable: true,
            }),
            field("minimum_order_value", "currency"),
            field("usage_limit", "integer"),
            field("expires_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "expired", "disabled"],
            }),
        ],
    }),

    // ============================================================
    // 10 — LOGISTICS
    // ============================================================

    definition({
        id: "shipment",
        name: "Shipment",
        category: "LOGISTICS",
        icon: "🚚",
        description:
            "Shipment record for tracking physical goods from fulfillment through delivery.",
        tags: ["shipment", "logistics", "delivery", "fulfillment"],
        popularity: 94,
        featured: true,
        fields: [
            field("shipment_id", "string", {
                required: true,
                unique: true,
            }),
            field("order_id", "string", {
                required: true,
            }),
            field("tracking_number", "string", {
                searchable: true,
                unique: true,
            }),
            field("carrier", "string", {
                required: true,
                searchable: true,
            }),
            field("shipping_method", "string"),
            field("ship_date", "date", {
                sortable: true,
            }),
            field("estimated_delivery_date", "date"),
            field("delivered_at", "datetime"),
            field("status", "select", {
                required: true,
                options: [
                    "label_created",
                    "in_transit",
                    "out_for_delivery",
                    "delivered",
                    "exception",
                    "returned",
                ],
            }),
        ],
    }),

    definition({
        id: "delivery-address",
        name: "Delivery Address",
        category: "LOGISTICS",
        icon: "📍",
        description:
            "Structured postal destination used for customer deliveries and logistics operations.",
        tags: ["address", "delivery", "shipping", "logistics"],
        popularity: 87,
        fields: [
            field("address_id", "string", {
                required: true,
                unique: true,
            }),
            field("recipient_name", "string", {
                required: true,
                searchable: true,
            }),
            field("company", "string", {
                searchable: true,
            }),
            field("address_line_1", "string", {
                required: true,
            }),
            field("address_line_2", "string"),
            field("city", "string", {
                required: true,
                searchable: true,
            }),
            field("postal_code", "string", {
                required: true,
                searchable: true,
            }),
            field("country", "string", {
                required: true,
                searchable: true,
            }),
        ],
    }),

    // ============================================================
    // 11 — PROCUREMENT
    // ============================================================

    definition({
        id: "supplier",
        name: "Supplier",
        category: "PROCUREMENT",
        icon: "🏢",
        description:
            "Supplier organization record for purchasing, sourcing, contracts and vendor management.",
        tags: ["supplier", "vendor", "procurement", "purchasing"],
        popularity: 91,
        fields: [
            field("supplier_id", "string", {
                required: true,
                unique: true,
            }),
            field("company_name", "string", {
                required: true,
                searchable: true,
            }),
            field("supplier_code", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("contact_name", "string", {
                searchable: true,
            }),
            field("email", "email"),
            field("phone", "phone"),
            field("payment_terms", "string"),
            field("rating", "number", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["prospective", "approved", "suspended", "inactive"],
            }),
        ],
    }),

    definition({
        id: "purchase-order",
        name: "Purchase Order",
        category: "PROCUREMENT",
        icon: "📝",
        description:
            "Formal purchase request issued to a supplier for products, services or materials.",
        tags: ["purchase-order", "procurement", "supplier", "purchasing"],
        popularity: 90,
        fields: [
            field("purchase_order_id", "string", {
                required: true,
                unique: true,
            }),
            field("po_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("supplier_id", "string", {
                required: true,
            }),
            field("requester_id", "string", {
                required: true,
            }),
            field("order_date", "date", {
                required: true,
            }),
            field("expected_delivery_date", "date"),
            field("subtotal", "currency", {
                required: true,
            }),
            field("tax_total", "currency"),
            field("total", "currency", {
                required: true,
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["draft", "pending_approval", "approved", "sent", "received", "closed"],
            }),
        ],
    }),

    definition({
        id: "purchase-request",
        name: "Purchase Request",
        category: "PROCUREMENT",
        icon: "🛒",
        description:
            "Internal request to purchase goods or services before procurement approval.",
        tags: ["purchase", "request", "procurement", "approval"],
        popularity: 81,
        fields: [
            field("request_id", "string", {
                required: true,
                unique: true,
            }),
            field("requester_id", "string", {
                required: true,
            }),
            field("department", "string", {
                required: true,
                searchable: true,
            }),
            field("item_description", "text", {
                required: true,
            }),
            field("quantity", "number", {
                required: true,
            }),
            field("estimated_cost", "currency", {
                required: true,
                sortable: true,
            }),
            field("required_by", "date"),
            field("approval_status", "select", {
                required: true,
                options: ["pending", "approved", "rejected"],
            }),
        ],
    }),

    // ============================================================
    // 12 — LEGAL & COMPLIANCE
    // ============================================================

    definition({
        id: "contract",
        name: "Contract",
        category: "LEGAL & COMPLIANCE",
        icon: "📜",
        description:
            "Commercial or operational contract with parties, dates, value, terms and lifecycle status.",
        tags: ["contract", "legal", "agreement", "compliance"],
        popularity: 95,
        featured: true,
        fields: [
            field("contract_id", "string", {
                required: true,
                unique: true,
            }),
            field("contract_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("contract_type", "select", {
                required: true,
                options: ["customer", "supplier", "employment", "nda", "partnership", "other"],
            }),
            field("counterparty_id", "string", {
                required: true,
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("end_date", "date"),
            field("contract_value", "currency", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["draft", "review", "active", "expired", "terminated"],
            }),
        ],
    }),

    definition({
        id: "compliance-case",
        name: "Compliance Case",
        category: "LEGAL & COMPLIANCE",
        icon: "🛡",
        description:
            "Compliance investigation or case used to track obligations, findings, actions and resolution.",
        tags: ["compliance", "risk", "legal", "governance"],
        popularity: 78,
        fields: [
            field("case_id", "string", {
                required: true,
                unique: true,
            }),
            field("case_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("case_type", "select", {
                required: true,
                options: ["privacy", "regulatory", "policy", "audit", "other"],
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("owner_id", "string", {
                required: true,
            }),
            field("risk_level", "select", {
                required: true,
                options: ["low", "medium", "high", "critical"],
            }),
            field("opened_at", "datetime", {
                required: true,
            }),
            field("resolved_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["open", "investigating", "remediating", "resolved", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 13 — IT & SOFTWARE
    // ============================================================

    definition({
        id: "software-application",
        name: "Software Application",
        category: "IT & SOFTWARE",
        icon: "💻",
        description:
            "Application inventory record for software ownership, lifecycle, criticality and technical management.",
        tags: ["software", "application", "it", "technology", "asset"],
        popularity: 88,
        fields: [
            field("application_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("owner_id", "string", {
                required: true,
            }),
            field("vendor", "string", {
                searchable: true,
            }),
            field("version", "string"),
            field("criticality", "select", {
                required: true,
                options: ["low", "medium", "high", "critical"],
            }),
            field("environment", "select", {
                options: ["development", "staging", "production"],
            }),
            field("status", "select", {
                required: true,
                options: ["planned", "active", "maintenance", "retired"],
            }),
        ],
    }),

    definition({
        id: "api-integration",
        name: "API Integration",
        category: "IT & SOFTWARE",
        icon: "🔌",
        description:
            "Integration definition describing an external API connection, authentication and operational status.",
        tags: ["api", "integration", "software", "automation"],
        popularity: 92,
        featured: true,
        fields: [
            field("integration_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("provider", "string", {
                required: true,
                searchable: true,
            }),
            field("base_url", "url", {
                required: true,
            }),
            field("authentication_type", "select", {
                required: true,
                options: ["api_key", "oauth2", "basic", "bearer", "none"],
            }),
            field("environment", "select", {
                required: true,
                options: ["sandbox", "staging", "production"],
            }),
            field("last_sync_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["connected", "degraded", "disconnected", "disabled"],
            }),
        ],
    }),

    definition({
        id: "it-asset",
        name: "IT Asset",
        category: "IT & SOFTWARE",
        icon: "🖥",
        description:
            "Trackable technology asset such as laptop, monitor, server or mobile device.",
        tags: ["asset", "it", "hardware", "inventory"],
        popularity: 84,
        fields: [
            field("asset_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("asset_tag", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("asset_type", "select", {
                required: true,
                options: ["laptop", "desktop", "monitor", "server", "mobile", "network", "other"],
            }),
            field("manufacturer", "string", {
                searchable: true,
            }),
            field("model", "string", {
                searchable: true,
            }),
            field("serial_number", "string", {
                unique: true,
                searchable: true,
            }),
            field("assigned_to", "string"),
            field("purchase_date", "date"),
            field("status", "select", {
                required: true,
                options: ["available", "assigned", "repair", "retired", "lost"],
            }),
        ],
    }),

    // ============================================================
    // 14 — EVENTS & SCHEDULING
    // ============================================================

    definition({
        id: "event",
        name: "Business Event",
        category: "EVENTS & SCHEDULING",
        icon: "📅",
        description:
            "Business event or scheduled activity with attendees, location, timing and status.",
        tags: ["event", "calendar", "meeting", "scheduling"],
        popularity: 93,
        featured: true,
        fields: [
            field("event_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("event_type", "select", {
                required: true,
                options: ["meeting", "conference", "webinar", "training", "appointment", "other"],
            }),
            field("start_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("end_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("location", "string", {
                searchable: true,
            }),
            field("organizer_id", "string"),
            field("status", "select", {
                required: true,
                options: ["draft", "scheduled", "cancelled", "completed"],
            }),
        ],
    }),

    definition({
        id: "appointment",
        name: "Appointment",
        category: "EVENTS & SCHEDULING",
        icon: "🗓",
        description:
            "One-to-one or small-group scheduled appointment between people or organizations.",
        tags: ["appointment", "calendar", "booking", "schedule"],
        popularity: 86,
        fields: [
            field("appointment_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string"),
            field("staff_id", "string", {
                required: true,
            }),
            field("service_type", "string", {
                required: true,
                searchable: true,
            }),
            field("start_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("end_at", "datetime", {
                required: true,
            }),
            field("location", "string"),
            field("notes", "text"),
            field("status", "select", {
                required: true,
                options: ["scheduled", "confirmed", "completed", "cancelled", "no_show"],
            }),
        ],
    }),

    // ============================================================
    // 15 — CONTENT & DOCUMENTS
    // ============================================================

    definition({
        id: "document",
        name: "Business Document",
        category: "CONTENT & DOCUMENTS",
        icon: "📄",
        description:
            "General business document record for policies, reports, contracts, forms and uploaded files.",
        tags: ["document", "file", "content", "records"],
        popularity: 91,
        fields: [
            field("document_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("document_type", "select", {
                required: true,
                options: ["report", "policy", "contract", "form", "presentation", "other"],
            }),
            field("description", "text"),
            field("file_url", "url", {
                required: true,
            }),
            field("owner_id", "string"),
            field("version", "string"),
            field("uploaded_at", "datetime", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "archived"],
            }),
        ],
    }),

    definition({
        id: "content-page",
        name: "Content Page",
        category: "CONTENT & DOCUMENTS",
        icon: "📰",
        description:
            "Publishable content page for websites, portals, help centers and digital experiences.",
        tags: ["content", "cms", "page", "website", "publishing"],
        popularity: 84,
        fields: [
            field("page_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("slug", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("excerpt", "text"),
            field("content", "rich_text", {
                required: true,
            }),
            field("author_id", "string"),
            field("published_at", "datetime"),
            field("seo_title", "string"),
            field("seo_description", "text"),
            field("status", "select", {
                required: true,
                options: ["draft", "review", "published", "archived"],
            }),
        ],
    }),

    // ============================================================
    // 16 — ANALYTICS & DATA
    // ============================================================

    definition({
        id: "business-metric",
        name: "Business Metric",
        category: "ANALYTICS & DATA",
        icon: "📊",
        description:
            "Measured business KPI used for dashboards, reporting and operational decision making.",
        tags: ["metric", "kpi", "analytics", "reporting", "data"],
        popularity: 89,
        fields: [
            field("metric_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("metric_type", "select", {
                required: true,
                options: ["count", "sum", "average", "percentage", "ratio", "currency"],
            }),
            field("value", "number", {
                required: true,
                sortable: true,
            }),
            field("unit", "string"),
            field("period_start", "date", {
                required: true,
            }),
            field("period_end", "date", {
                required: true,
            }),
        ],
    }),

    definition({
        id: "data-import",
        name: "Data Import",
        category: "ANALYTICS & DATA",
        icon: "⬆",
        description:
            "Controlled data import job used to track source files, processing, validation and results.",
        tags: ["import", "data", "etl", "integration", "analytics"],
        popularity: 76,
        fields: [
            field("import_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("source_type", "select", {
                required: true,
                options: ["csv", "excel", "json", "api", "database"],
            }),
            field("source_name", "string", {
                searchable: true,
            }),
            field("file_url", "url"),
            field("row_count", "integer", {
                sortable: true,
            }),
            field("error_count", "integer", {
                sortable: true,
            }),
            field("started_at", "datetime"),
            field("completed_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["queued", "processing", "completed", "failed", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 17 — PARTNERSHIPS
    // ============================================================

    definition({
        id: "partner",
        name: "Business Partner",
        category: "PARTNERSHIPS",
        icon: "🤝",
        description:
            "Partner organization or individual participating in commercial, channel or strategic relationships.",
        tags: ["partner", "partnership", "channel", "business"],
        popularity: 87,
        fields: [
            field("partner_id", "string", {
                required: true,
                unique: true,
            }),
            field("company_name", "string", {
                required: true,
                searchable: true,
            }),
            field("partner_type", "select", {
                required: true,
                options: ["reseller", "referral", "technology", "strategic", "affiliate", "other"],
            }),
            field("primary_contact", "string", {
                searchable: true,
            }),
            field("email", "email"),
            field("website", "url"),
            field("commission_rate", "percentage"),
            field("start_date", "date"),
            field("status", "select", {
                required: true,
                options: ["prospect", "active", "paused", "terminated"],
            }),
        ],
    }),

    // ============================================================
    // 18 — RISK
    // ============================================================

    definition({
        id: "business-risk",
        name: "Business Risk",
        category: "RISK & GOVERNANCE",
        icon: "⚠",
        description:
            "Risk register item used to identify, assess, assign and mitigate organizational risk.",
        tags: ["risk", "governance", "compliance", "management"],
        popularity: 83,
        fields: [
            field("risk_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("category", "select", {
                required: true,
                options: ["financial", "operational", "legal", "technology", "security", "strategic"],
            }),
            field("likelihood", "select", {
                required: true,
                options: ["rare", "unlikely", "possible", "likely", "almost_certain"],
            }),
            field("impact", "select", {
                required: true,
                options: ["low", "medium", "high", "critical"],
            }),
            field("owner_id", "string"),
            field("mitigation_plan", "text"),
            field("status", "select", {
                required: true,
                options: ["identified", "assessed", "mitigating", "accepted", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 19 — SECURITY
    // ============================================================

    definition({
        id: "security-incident",
        name: "Security Incident",
        category: "SECURITY",
        icon: "🔐",
        description:
            "Security incident record for investigating suspicious activity, breaches and security events.",
        tags: ["security", "incident", "cybersecurity", "risk"],
        popularity: 80,
        fields: [
            field("incident_id", "string", {
                required: true,
                unique: true,
            }),
            field("incident_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("severity", "select", {
                required: true,
                options: ["low", "medium", "high", "critical"],
            }),
            field("incident_type", "select", {
                required: true,
                options: ["access", "malware", "data_loss", "phishing", "availability", "other"],
            }),
            field("reported_by", "string"),
            field("assigned_to", "string"),
            field("detected_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("resolved_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["open", "investigating", "contained", "resolved", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 20 — FACILITIES
    // ============================================================

    definition({
        id: "facility",
        name: "Facility",
        category: "FACILITIES",
        icon: "🏢",
        description:
            "Physical facility or site used for offices, operations, production or service delivery.",
        tags: ["facility", "building", "location", "operations"],
        popularity: 73,
        fields: [
            field("facility_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("facility_type", "select", {
                required: true,
                options: ["office", "warehouse", "store", "factory", "data_center", "other"],
            }),
            field("address", "address", {
                required: true,
            }),
            field("manager_id", "string"),
            field("capacity", "integer", {
                sortable: true,
            }),
            field("opening_date", "date"),
            field("status", "select", {
                required: true,
                options: ["planned", "active", "maintenance", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 21 — SERVICE DELIVERY
    // ============================================================

    definition({
        id: "service",
        name: "Service",
        category: "SERVICE DELIVERY",
        icon: "✨",
        description:
            "Commercial service definition used for service catalogs, pricing and delivery workflows.",
        tags: ["service", "catalog", "offering", "pricing"],
        popularity: 92,
        featured: true,
        isNew: true,
        fields: [
            field("service_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "rich_text"),
            field("service_category", "string", {
                searchable: true,
            }),
            field("price", "currency", {
                required: true,
                sortable: true,
            }),
            field("billing_model", "select", {
                required: true,
                options: ["fixed", "hourly", "usage", "subscription", "custom"],
            }),
            field("estimated_duration", "number"),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "paused", "retired"],
            }),
        ],
    }),

    // ============================================================
    // 22 — FEEDBACK
    // ============================================================

    definition({
        id: "customer-feedback",
        name: "Customer Feedback",
        category: "CUSTOMER EXPERIENCE",
        icon: "💡",
        description:
            "Customer feedback record for satisfaction analysis, product improvement and experience management.",
        tags: ["feedback", "customer", "experience", "survey", "nps"],
        popularity: 88,
        isNew: true,
        fields: [
            field("feedback_id", "string", {
                required: true,
                unique: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("feedback_type", "select", {
                required: true,
                options: ["review", "survey", "complaint", "suggestion", "nps"],
            }),
            field("rating", "number", {
                sortable: true,
            }),
            field("comment", "text"),
            field("source", "string", {
                searchable: true,
            }),
            field("submitted_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["new", "reviewed", "actioned", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 23 — MEMBERSHIP
    // ============================================================

    definition({
        id: "membership",
        name: "Membership",
        category: "MEMBERSHIP",
        icon: "🎟",
        description:
            "Membership record for organizations, clubs, communities and recurring member programs.",
        tags: ["membership", "member", "subscription", "community"],
        popularity: 81,
        fields: [
            field("membership_id", "string", {
                required: true,
                unique: true,
            }),
            field("member_id", "string", {
                required: true,
            }),
            field("membership_type", "string", {
                required: true,
                searchable: true,
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("end_date", "date"),
            field("renewal_date", "date"),
            field("price", "currency"),
            field("status", "select", {
                required: true,
                options: ["pending", "active", "paused", "expired", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 24 — SURVEY
    // ============================================================

    definition({
        id: "survey",
        name: "Survey",
        category: "CUSTOMER EXPERIENCE",
        icon: "📝",
        description:
            "Structured survey definition containing questions, audience configuration and publication status.",
        tags: ["survey", "questionnaire", "feedback", "research"],
        popularity: 79,
        isNew: true,
        fields: [
            field("survey_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("survey_type", "select", {
                required: true,
                options: ["customer", "employee", "market", "research", "nps"],
            }),
            field("questions", "json", {
                required: true,
            }),
            field("audience_id", "string"),
            field("start_at", "datetime"),
            field("end_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "published", "paused", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 25 — ORGANIZATION
    // ============================================================

    definition({
        id: "department",
        name: "Department",
        category: "ORGANIZATION",
        icon: "🏛",
        description:
            "Organizational department used to structure teams, budgets, ownership and reporting lines.",
        tags: ["department", "organization", "hr", "management"],
        popularity: 76,
        fields: [
            field("department_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("code", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("manager_id", "string"),
            field("parent_department_id", "string"),
            field("cost_center", "string", {
                searchable: true,
            }),
            field("budget", "currency"),
            field("status", "select", {
                required: true,
                options: ["active", "inactive"],
            }),
        ],
    }),

    // ============================================================
    // 26 — LOCATION
    // ============================================================

    definition({
        id: "business-location",
        name: "Business Location",
        category: "ORGANIZATION",
        icon: "📍",
        description:
            "Business location record for offices, branches, stores and operational sites.",
        tags: ["location", "office", "branch", "organization"],
        popularity: 75,
        fields: [
            field("location_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("location_type", "select", {
                required: true,
                options: ["office", "branch", "store", "remote", "other"],
            }),
            field("address", "address"),
            field("city", "string", {
                searchable: true,
            }),
            field("country", "string", {
                searchable: true,
            }),
            field("timezone", "string"),
            field("status", "select", {
                required: true,
                options: ["active", "inactive"],
            }),
        ],
    }),

    // ============================================================
    // 27 — ACCOUNTING
    // ============================================================

    definition({
        id: "accounting-entry",
        name: "Accounting Entry",
        category: "ACCOUNTING",
        icon: "🧮",
        description:
            "Financial ledger entry used for bookkeeping, reconciliation and accounting reporting.",
        tags: ["accounting", "ledger", "finance", "bookkeeping"],
        popularity: 85,
        fields: [
            field("entry_id", "string", {
                required: true,
                unique: true,
            }),
            field("account_code", "string", {
                required: true,
                searchable: true,
            }),
            field("entry_type", "select", {
                required: true,
                options: ["debit", "credit"],
            }),
            field("amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("currency", "string", {
                required: true,
                defaultValue: "EUR",
            }),
            field("reference_type", "string"),
            field("reference_id", "string"),
            field("description", "text"),
            field("posted_at", "datetime", {
                required: true,
                sortable: true,
            }),
        ],
    }),

    // ============================================================
    // 28 — ASSETS
    // ============================================================

    definition({
        id: "business-asset",
        name: "Business Asset",
        category: "ASSET MANAGEMENT",
        icon: "🏷",
        description:
            "General business asset record for equipment, property, technology or other owned resources.",
        tags: ["asset", "property", "equipment", "management"],
        popularity: 77,
        fields: [
            field("asset_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("asset_type", "string", {
                required: true,
                searchable: true,
            }),
            field("serial_number", "string", {
                unique: true,
                searchable: true,
            }),
            field("purchase_date", "date"),
            field("purchase_cost", "currency"),
            field("current_value", "currency"),
            field("assigned_to", "string"),
            field("status", "select", {
                required: true,
                options: ["active", "maintenance", "disposed", "lost"],
            }),
        ],
    }),

    // ============================================================
    // 29 — QUALITY
    // ============================================================

    definition({
        id: "quality-inspection",
        name: "Quality Inspection",
        category: "QUALITY",
        icon: "🔍",
        description:
            "Inspection record for evaluating products, processes or operational output against quality criteria.",
        tags: ["quality", "inspection", "manufacturing", "operations"],
        popularity: 72,
        fields: [
            field("inspection_id", "string", {
                required: true,
                unique: true,
            }),
            field("inspection_type", "select", {
                required: true,
                options: ["incoming", "in_process", "final", "audit", "supplier"],
            }),
            field("subject_id", "string", {
                required: true,
            }),
            field("inspector_id", "string", {
                required: true,
            }),
            field("inspection_date", "date", {
                required: true,
                sortable: true,
            }),
            field("score", "number", {
                sortable: true,
            }),
            field("findings", "text"),
            field("result", "select", {
                required: true,
                options: ["pass", "conditional", "fail"],
            }),
            field("status", "select", {
                required: true,
                options: ["scheduled", "in_progress", "completed"],
            }),
        ],
    }),

    // ============================================================
    // 30 — CASE MANAGEMENT
    // ============================================================

    definition({
        id: "business-case",
        name: "Business Case",
        category: "CASE MANAGEMENT",
        icon: "🗂",
        description:
            "General-purpose case record for structured business investigations, requests and resolutions.",
        tags: ["case", "workflow", "operations", "management"],
        popularity: 74,
        fields: [
            field("case_id", "string", {
                required: true,
                unique: true,
            }),
            field("case_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("case_type", "string", {
                required: true,
                searchable: true,
            }),
            field("owner_id", "string", {
                required: true,
            }),
            field("priority", "select", {
                required: true,
                options: ["low", "medium", "high", "critical"],
            }),
            field("opened_at", "datetime", {
                required: true,
            }),
            field("closed_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["new", "open", "in_progress", "resolved", "closed"],
            }),
        ],
    }),

    // ============================================================
    // 31 — USER & ACCESS
    // ============================================================

    definition({
        id: "user-account",
        name: "User Account",
        category: "USER & ACCESS",
        icon: "🔑",
        description:
            "Application user account containing identity, access status and account lifecycle information.",
        tags: ["user", "account", "authentication", "identity"],
        popularity: 99,
        featured: true,
        fields: [
            field("user_id", "string", {
                required: true,
                unique: true,
            }),
            field("email", "email", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("first_name", "string", {
                searchable: true,
            }),
            field("last_name", "string", {
                searchable: true,
            }),
            field("role", "string", {
                required: true,
                searchable: true,
            }),
            field("last_login_at", "datetime", {
                sortable: true,
            }),
            field("email_verified", "boolean", {
                required: true,
            }),
            field("status", "select", {
                required: true,
                options: ["invited", "active", "locked", "disabled"],
            }),
        ],
    }),

    // ============================================================
    // 32 — AUDIT
    // ============================================================

    definition({
        id: "audit-log",
        name: "Audit Log",
        category: "SECURITY & AUDIT",
        icon: "🧾",
        description:
            "Immutable activity record capturing important system or user actions for auditability.",
        tags: ["audit", "log", "security", "compliance", "activity"],
        popularity: 91,
        featured: true,
        fields: [
            field("log_id", "string", {
                required: true,
                unique: true,
            }),
            field("actor_id", "string", {
                required: true,
                searchable: true,
            }),
            field("action", "string", {
                required: true,
                searchable: true,
            }),
            field("resource_type", "string", {
                required: true,
                searchable: true,
            }),
            field("resource_id", "string", {
                required: true,
                searchable: true,
            }),
            field("ip_address", "string"),
            field("metadata", "json"),
            field("occurred_at", "datetime", {
                required: true,
                sortable: true,
                system: true,
            }),
        ],
    }),

    // ============================================================
    // 33 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "service-level-agreement",
        name: "Service Level Agreement",
        category: "SERVICE DELIVERY",
        icon: "⏱",
        description:
            "SLA definition for contractual service commitments, response targets and resolution expectations.",
        tags: ["sla", "service", "support", "contract", "operations"],
        popularity: 73,
        isNew: true,
        fields: [
            field("sla_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("customer_id", "string"),
            field("service_id", "string", {
                required: true,
            }),
            field("response_target_minutes", "integer", {
                required: true,
            }),
            field("resolution_target_minutes", "integer", {
                required: true,
            }),
            field("business_hours_only", "boolean", {
                defaultValue: true,
            }),
            field("effective_from", "date", {
                required: true,
            }),
            field("effective_until", "date"),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "expired", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 34 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "pricing-plan",
        name: "Pricing Plan",
        category: "PRODUCTS & INVENTORY",
        icon: "💎",
        description:
            "Commercial pricing plan for subscriptions, packages, tiers and recurring offerings.",
        tags: ["pricing", "plan", "subscription", "saas", "commerce"],
        popularity: 96,
        featured: true,
        isNew: true,
        fields: [
            field("plan_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("plan_type", "select", {
                required: true,
                options: ["free", "standard", "professional", "enterprise", "custom"],
            }),
            field("price", "currency", {
                required: true,
                sortable: true,
            }),
            field("billing_interval", "select", {
                required: true,
                options: ["monthly", "quarterly", "yearly", "one_time"],
            }),
            field("included_units", "number"),
            field("features", "json"),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "archived"],
            }),
        ],
    }),

    // ============================================================
    // 35 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "vendor-contract",
        name: "Vendor Contract",
        category: "PROCUREMENT",
        icon: "🤝",
        description:
            "Supplier agreement for commercial terms, renewal dates, commitments and procurement governance.",
        tags: ["vendor", "supplier", "contract", "procurement"],
        popularity: 71,
        isNew: true,
        fields: [
            field("contract_id", "string", {
                required: true,
                unique: true,
            }),
            field("supplier_id", "string", {
                required: true,
            }),
            field("contract_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("start_date", "date", {
                required: true,
            }),
            field("renewal_date", "date"),
            field("annual_value", "currency", {
                sortable: true,
            }),
            field("owner_id", "string"),
            field("status", "select", {
                required: true,
                options: ["draft", "review", "active", "renewal", "terminated"],
            }),
        ],
    }),

    // ============================================================
    // 36 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "customer-segment",
        name: "Customer Segment",
        category: "CUSTOMER & CRM",
        icon: "🎯",
        description:
            "Customer segmentation definition used for targeting, reporting and personalized commercial workflows.",
        tags: ["segment", "customer", "crm", "marketing", "analytics"],
        popularity: 86,
        isNew: true,
        fields: [
            field("segment_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "text"),
            field("criteria", "json", {
                required: true,
            }),
            field("customer_count", "integer", {
                sortable: true,
            }),
            field("owner_id", "string"),
            field("last_calculated_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "active", "archived"],
            }),
        ],
    }),

    // ============================================================
    // 37 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "refund",
        name: "Refund",
        category: "FINANCE",
        icon: "↩",
        description:
            "Financial refund record associated with a customer payment, order or invoice.",
        tags: ["refund", "finance", "payment", "customer"],
        popularity: 84,
        isNew: true,
        fields: [
            field("refund_id", "string", {
                required: true,
                unique: true,
            }),
            field("payment_id", "string", {
                required: true,
            }),
            field("order_id", "string"),
            field("customer_id", "string", {
                required: true,
            }),
            field("amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("reason", "select", {
                required: true,
                options: ["customer_request", "duplicate", "product_issue", "fraud", "other"],
            }),
            field("processed_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["requested", "approved", "processing", "completed", "rejected"],
            }),
        ],
    }),

    // ============================================================
    // 38 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "return-request",
        name: "Product Return",
        category: "E-COMMERCE",
        icon: "↩",
        description:
            "Customer return request for purchased products including reason, inspection and resolution.",
        tags: ["return", "ecommerce", "customer", "order", "refund"],
        popularity: 82,
        isNew: true,
        fields: [
            field("return_id", "string", {
                required: true,
                unique: true,
            }),
            field("order_id", "string", {
                required: true,
            }),
            field("customer_id", "string", {
                required: true,
            }),
            field("product_id", "string", {
                required: true,
            }),
            field("quantity", "number", {
                required: true,
            }),
            field("reason", "select", {
                required: true,
                options: [
                    "damaged",
                    "wrong_item",
                    "not_as_expected",
                    "changed_mind",
                    "defective",
                    "other",
                ],
            }),
            field("requested_at", "datetime", {
                required: true,
            }),
            field("resolution", "select", {
                options: ["refund", "replacement", "credit", "rejected"],
            }),
            field("status", "select", {
                required: true,
                options: ["requested", "approved", "received", "inspected", "completed", "rejected"],
            }),
        ],
    }),

    // ============================================================
    // 39 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "sla-breach",
        name: "SLA Breach",
        category: "SERVICE DELIVERY",
        icon: "🚨",
        description:
            "Service-level breach record used to monitor missed contractual response or resolution commitments.",
        tags: ["sla", "breach", "support", "service", "operations"],
        popularity: 68,
        isNew: true,
        fields: [
            field("breach_id", "string", {
                required: true,
                unique: true,
            }),
            field("sla_id", "string", {
                required: true,
            }),
            field("ticket_id", "string"),
            field("customer_id", "string"),
            field("breach_type", "select", {
                required: true,
                options: ["response", "resolution", "availability", "other"],
            }),
            field("target_at", "datetime", {
                required: true,
            }),
            field("actual_at", "datetime"),
            field("duration_minutes", "integer", {
                sortable: true,
            }),
            field("severity", "select", {
                required: true,
                options: ["minor", "major", "critical"],
            }),
            field("status", "select", {
                required: true,
                options: ["open", "acknowledged", "resolved", "waived"],
            }),
        ],
    }),

    // ============================================================
    // 40 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "commission",
        name: "Sales Commission",
        category: "SALES",
        icon: "💰",
        description:
            "Sales commission calculation record connecting commercial performance to compensation.",
        tags: ["commission", "sales", "compensation", "revenue"],
        popularity: 80,
        isNew: true,
        fields: [
            field("commission_id", "string", {
                required: true,
                unique: true,
            }),
            field("employee_id", "string", {
                required: true,
            }),
            field("opportunity_id", "string"),
            field("order_id", "string"),
            field("commission_rate", "percentage", {
                required: true,
            }),
            field("eligible_amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("commission_amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("period", "string", {
                required: true,
            }),
            field("status", "select", {
                required: true,
                options: ["calculated", "approved", "paid", "reversed"],
            }),
        ],
    }),

    // ============================================================
    // 41 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "product-review",
        name: "Product Review",
        category: "CUSTOMER EXPERIENCE",
        icon: "⭐",
        description:
            "Customer review and rating attached to a product or service offering.",
        tags: ["review", "rating", "product", "customer", "experience"],
        popularity: 87,
        isNew: true,
        fields: [
            field("review_id", "string", {
                required: true,
                unique: true,
            }),
            field("product_id", "string", {
                required: true,
            }),
            field("customer_id", "string"),
            field("rating", "integer", {
                required: true,
                sortable: true,
            }),
            field("title", "string", {
                searchable: true,
            }),
            field("comment", "text"),
            field("verified_purchase", "boolean"),
            field("submitted_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["pending", "published", "hidden", "removed"],
            }),
        ],
    }),

    // ============================================================
    // 42 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "forecast",
        name: "Revenue Forecast",
        category: "ANALYTICS & DATA",
        icon: "🔮",
        description:
            "Forward-looking commercial forecast for revenue, pipeline and financial planning.",
        tags: ["forecast", "revenue", "sales", "analytics", "planning"],
        popularity: 78,
        isNew: true,
        fields: [
            field("forecast_id", "string", {
                required: true,
                unique: true,
            }),
            field("period", "string", {
                required: true,
                searchable: true,
            }),
            field("forecast_type", "select", {
                required: true,
                options: ["revenue", "sales", "cash_flow", "demand"],
            }),
            field("forecast_amount", "currency", {
                required: true,
                sortable: true,
            }),
            field("actual_amount", "currency", {
                sortable: true,
            }),
            field("confidence", "percentage", {
                sortable: true,
            }),
            field("owner_id", "string"),
            field("generated_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "published", "superseded"],
            }),
        ],
    }),

    // ============================================================
    // 43 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "notification",
        name: "Notification",
        category: "COMMUNICATION",
        icon: "🔔",
        description:
            "Application notification used for transactional alerts, reminders and customer communications.",
        tags: ["notification", "communication", "alert", "messaging"],
        popularity: 90,
        isNew: true,
        fields: [
            field("notification_id", "string", {
                required: true,
                unique: true,
            }),
            field("recipient_id", "string", {
                required: true,
            }),
            field("notification_type", "select", {
                required: true,
                options: ["email", "sms", "push", "in_app"],
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("message", "text", {
                required: true,
            }),
            field("action_url", "url"),
            field("scheduled_at", "datetime"),
            field("sent_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["queued", "scheduled", "sent", "failed", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 44 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "message",
        name: "Customer Message",
        category: "COMMUNICATION",
        icon: "💬",
        description:
            "Message record for customer conversations, internal communications and transactional messaging.",
        tags: ["message", "communication", "chat", "customer"],
        popularity: 89,
        isNew: true,
        fields: [
            field("message_id", "string", {
                required: true,
                unique: true,
            }),
            field("conversation_id", "string", {
                required: true,
            }),
            field("sender_id", "string", {
                required: true,
            }),
            field("recipient_id", "string"),
            field("message_type", "select", {
                required: true,
                options: ["text", "email", "system", "attachment"],
            }),
            field("content", "text", {
                required: true,
            }),
            field("attachment_url", "url"),
            field("sent_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("read_at", "datetime"),
        ],
    }),

    // ============================================================
    // 45 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "asset-maintenance",
        name: "Asset Maintenance",
        category: "ASSET MANAGEMENT",
        icon: "🔧",
        description:
            "Scheduled or corrective maintenance record for physical and technical business assets.",
        tags: ["maintenance", "asset", "equipment", "operations"],
        popularity: 69,
        isNew: true,
        fields: [
            field("maintenance_id", "string", {
                required: true,
                unique: true,
            }),
            field("asset_id", "string", {
                required: true,
            }),
            field("maintenance_type", "select", {
                required: true,
                options: ["preventive", "corrective", "inspection", "upgrade"],
            }),
            field("description", "text", {
                required: true,
            }),
            field("scheduled_date", "date", {
                required: true,
                sortable: true,
            }),
            field("completed_date", "date"),
            field("technician_id", "string"),
            field("cost", "currency", {
                sortable: true,
            }),
            field("status", "select", {
                required: true,
                options: ["scheduled", "in_progress", "completed", "cancelled"],
            }),
        ],
    }),

    // ============================================================
    // 46 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "time-entry",
        name: "Time Entry",
        category: "OPERATIONS",
        icon: "⏱",
        description:
            "Tracked work time used for project costing, billing, productivity and resource planning.",
        tags: ["time", "timesheet", "project", "billing", "operations"],
        popularity: 85,
        isNew: true,
        fields: [
            field("time_entry_id", "string", {
                required: true,
                unique: true,
            }),
            field("employee_id", "string", {
                required: true,
            }),
            field("project_id", "string"),
            field("task_id", "string"),
            field("work_date", "date", {
                required: true,
                sortable: true,
            }),
            field("hours", "number", {
                required: true,
                sortable: true,
            }),
            field("billable", "boolean", {
                required: true,
            }),
            field("billing_rate", "currency"),
            field("description", "text"),
            field("status", "select", {
                required: true,
                options: ["draft", "submitted", "approved", "rejected", "billed"],
            }),
        ],
    }),

    // ============================================================
    // 47 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "resource",
        name: "Business Resource",
        category: "OPERATIONS",
        icon: "🧰",
        description:
            "Bookable or allocatable business resource such as equipment, room, vehicle or specialist capacity.",
        tags: ["resource", "booking", "operations", "capacity"],
        popularity: 70,
        isNew: true,
        fields: [
            field("resource_id", "string", {
                required: true,
                unique: true,
            }),
            field("name", "string", {
                required: true,
                searchable: true,
            }),
            field("resource_type", "select", {
                required: true,
                options: ["room", "equipment", "vehicle", "person", "capacity", "other"],
            }),
            field("location", "string", {
                searchable: true,
            }),
            field("capacity", "number"),
            field("hourly_rate", "currency"),
            field("availability", "json"),
            field("status", "select", {
                required: true,
                options: ["available", "reserved", "maintenance", "inactive"],
            }),
        ],
    }),

    // ============================================================
    // 48 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "knowledge-item",
        name: "Knowledge Item",
        category: "CONTENT & DOCUMENTS",
        icon: "🧠",
        description:
            "Reusable organizational knowledge record for internal procedures, answers, guidance and expertise.",
        tags: ["knowledge", "documentation", "internal", "content"],
        popularity: 77,
        isNew: true,
        fields: [
            field("knowledge_id", "string", {
                required: true,
                unique: true,
            }),
            field("title", "string", {
                required: true,
                searchable: true,
            }),
            field("category", "string", {
                searchable: true,
            }),
            field("content", "rich_text", {
                required: true,
            }),
            field("owner_id", "string"),
            field("tags", "array"),
            field("last_reviewed_at", "datetime"),
            field("review_due_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["draft", "published", "needs_review", "archived"],
            }),
        ],
    }),

    // ============================================================
    // 49 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "integration-event",
        name: "Integration Event",
        category: "IT & SOFTWARE",
        icon: "⚡",
        description:
            "System integration event used to track inbound and outbound events between applications.",
        tags: ["integration", "event", "api", "automation", "software"],
        popularity: 74,
        isNew: true,
        fields: [
            field("event_id", "string", {
                required: true,
                unique: true,
            }),
            field("event_type", "string", {
                required: true,
                searchable: true,
            }),
            field("source_system", "string", {
                required: true,
                searchable: true,
            }),
            field("target_system", "string", {
                required: true,
                searchable: true,
            }),
            field("payload", "json", {
                required: true,
            }),
            field("correlation_id", "string", {
                searchable: true,
            }),
            field("occurred_at", "datetime", {
                required: true,
                sortable: true,
            }),
            field("processed_at", "datetime"),
            field("status", "select", {
                required: true,
                options: ["received", "processing", "processed", "failed", "ignored"],
            }),
        ],
    }),

    // ============================================================
    // 50 — NEW COMMERCIAL AREA
    // ============================================================

    definition({
        id: "business-request",
        name: "Business Request",
        category: "CASE MANAGEMENT",
        icon: "📨",
        description:
            "Flexible business request structure for internal or external requests that require structured processing.",
        tags: ["request", "workflow", "case", "operations", "service"],
        popularity: 83,
        featured: true,
        isNew: true,
        fields: [
            field("request_id", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("request_number", "string", {
                required: true,
                unique: true,
                searchable: true,
            }),
            field("requester_id", "string", {
                required: true,
            }),
            field("request_type", "string", {
                required: true,
                searchable: true,
            }),
            field("subject", "string", {
                required: true,
                searchable: true,
            }),
            field("description", "rich_text", {
                required: true,
            }),
            field("priority", "select", {
                required: true,
                options: ["low", "medium", "high", "urgent"],
            }),
            field("assigned_to", "string"),
            field("due_date", "date"),
            field("status", "select", {
                required: true,
                options: ["new", "triaged", "assigned", "in_progress", "completed", "cancelled"],
            }),
            field("created_at", "datetime", {
                required: true,
                system: true,
            }),
        ],
    }),
];

/*
 * ------------------------------------------------------------
 * Catalog validation
 * ------------------------------------------------------------
 *
 * This runs once when the module is imported.
 * It is intentionally strict so bad seed data is caught early.
 */

function validateCatalog(catalog) {
    const errors = [];

    if (!Array.isArray(catalog)) {
        throw new Error(
            "[DefinitionLibraryCatalog] Catalog must be an array."
        );
    }

    const ids = new Set();

    catalog.forEach((definitionItem, definitionIndex) => {
        const prefix =
            `[DefinitionLibraryCatalog] Definition #${definitionIndex + 1}`;

        if (!definitionItem.id) {
            errors.push(`${prefix}: missing id`);
        }

        if (!definitionItem.name) {
            errors.push(`${prefix}: missing name`);
        }

        if (!definitionItem.category) {
            errors.push(`${prefix}: missing category`);
        }

        if (!Array.isArray(definitionItem.fields)) {
            errors.push(`${prefix}: fields must be an array`);
        }

        if (ids.has(definitionItem.id)) {
            errors.push(`${prefix}: duplicate id "${definitionItem.id}"`);
        }

        ids.add(definitionItem.id);

        if (Array.isArray(definitionItem.fields)) {
            const fieldNames = new Set();

            definitionItem.fields.forEach((definitionField, fieldIndex) => {
                const fieldPrefix =
                    `${prefix} / Field #${fieldIndex + 1}`;

                if (!definitionField.name) {
                    errors.push(`${fieldPrefix}: missing name`);
                }

                if (!definitionField.type) {
                    errors.push(`${fieldPrefix}: missing type`);
                }

                if (fieldNames.has(definitionField.name)) {
                    errors.push(
                        `${fieldPrefix}: duplicate field "${definitionField.name}"`
                    );
                }

                fieldNames.add(definitionField.name);

                if (
                    definitionField.type === "select" &&
                    !Array.isArray(definitionField.options)
                ) {
                    errors.push(
                        `${fieldPrefix}: select field must contain options`
                    );
                }
            });
        }
    });

    if (errors.length > 0) {
        console.error(
            "[DefinitionLibraryCatalog] VALIDATION FAILED",
            errors
        );

        throw new Error(
            `Definition Library catalog validation failed with ${errors.length} error(s).`
        );
    }

    console.info(
        `[DefinitionLibraryCatalog] ✓ Validated ${catalog.length} definitions`
    );

    return true;
}

validateCatalog(DEFINITION_LIBRARY_CATALOG);

/*
 * ------------------------------------------------------------
 * Derived catalog metadata
 * ------------------------------------------------------------
 */

export const DEFINITION_LIBRARY_CATEGORIES = [
    ...new Set(
        DEFINITION_LIBRARY_CATALOG.map((item) => item.category)
    ),
].sort();

export const DEFINITION_LIBRARY_TAGS = [
    ...new Set(
        DEFINITION_LIBRARY_CATALOG.flatMap(
            (item) => item.tags || []
        )
    ),
].sort();

export const DEFINITION_LIBRARY_STATS = {
    total: DEFINITION_LIBRARY_CATALOG.length,

    featured: DEFINITION_LIBRARY_CATALOG.filter(
        (item) => item.featured
    ).length,

    new: DEFINITION_LIBRARY_CATALOG.filter(
        (item) => item.new
    ).length,

    active: DEFINITION_LIBRARY_CATALOG.filter(
        (item) => item.status === "active"
    ).length,

    categories: DEFINITION_LIBRARY_CATEGORIES.length,

    fields: DEFINITION_LIBRARY_CATALOG.reduce(
        (total, item) => total + item.fields.length,
        0
    ),
};

/*
 * ------------------------------------------------------------
 * Helper functions
 * ------------------------------------------------------------
 */

export function getDefinitionById(id) {
    return DEFINITION_LIBRARY_CATALOG.find(
        (item) => item.id === id
    ) || null;
}

export function getDefinitionsByCategory(category) {
    if (!category || category === "ALL") {
        return [...DEFINITION_LIBRARY_CATALOG];
    }

    return DEFINITION_LIBRARY_CATALOG.filter(
        (item) => item.category === category
    );
}

export function getFeaturedDefinitions() {
    return DEFINITION_LIBRARY_CATALOG.filter(
        (item) => item.featured
    );
}

export function getNewDefinitions() {
    return DEFINITION_LIBRARY_CATALOG.filter(
        (item) => item.new
    );
}

export function getPopularDefinitions(limit = 10) {
    return [...DEFINITION_LIBRARY_CATALOG]
        .sort((a, b) => b.popularity - a.popularity)
        .slice(0, limit);
}

/*
 * Default export
 */

export default DEFINITION_LIBRARY_CATALOG;