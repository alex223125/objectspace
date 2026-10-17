
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["count", "empty", "error", "list"]

    static values = {
        adminUrlTemplate: String
    }

    connect() {
        this.entities = []
        this.relationships = []
        this.activeCard = null
        this.closeTimer = null
        this.onDocumentKeydown = this.handleDocumentKeydown.bind(this)

        document.addEventListener("keydown", this.onDocumentKeydown)
    }

    disconnect() {
        document.removeEventListener("keydown", this.onDocumentKeydown)
        this.removePopup()
        clearTimeout(this.closeTimer)
    }

    render(event) {
        const detail = event.detail || {}

        if (detail.error) {
            this.showError(detail.error)
            return
        }

        this.entities = Array.isArray(detail.entities)
            ? detail.entities
            : Array.isArray(detail.nodes)
                ? detail.nodes
                : []

        this.relationships = Array.isArray(detail.relationships)
            ? detail.relationships
            : Array.isArray(detail.edges)
                ? detail.edges
                : []

        this.removePopup()
        this.clearList()

        if (detail.cleared) {
            this.showEmpty()
            return
        }

        if (this.hasErrorTarget) {
            this.errorTarget.classList.add("hidden")
            this.errorTarget.textContent = ""
        }

        if (this.hasCountTarget) {
            this.countTarget.textContent =
                `${this.entities.length} ${this.entities.length === 1 ? "entity" : "entities"} · ` +
                `${this.relationships.length} ${this.relationships.length === 1 ? "relationship" : "relationships"}`
        }

        if (this.entities.length === 0) {
            this.showEmpty("No matching entities were returned for this search.")
            return
        }

        this.emptyTarget.classList.add("hidden")
        this.listTarget.classList.remove("hidden")

        this.entities.forEach((entity, index) => {
            this.listTarget.appendChild(this.createEntityCard(entity, index))
        })
    }


    createEntityCard(entity, index) {
        const card = document.createElement("article")

        card.className =
            "relative rounded-2xl border border-slate-200 bg-white p-4 transition " +
            "hover:border-orange-300 hover:bg-orange-50/30 hover:shadow-md " +
            "focus-within:border-orange-300"

        const heading = document.createElement("div")
        heading.className = "flex flex-wrap items-start justify-between gap-3"

        const textContainer = document.createElement("div")
        textContainer.className = "min-w-0 flex-1"

        const title = document.createElement("h3")
        title.className = "break-words text-base font-black text-slate-900"
        title.textContent = this.entityTitle(entity, index)

        const metadata = document.createElement("p")
        metadata.className = "mt-1 break-words text-sm text-slate-600"

        const type = this.firstValue(entity, [
            "entity_type_name",
            "entity_type",
            "type",
            "entity_type_id"
        ])

        const id = this.firstValue(entity, [
            "id",
            "identifier",
            "external_id",
            "slug"
        ])

        metadata.textContent = [
            type ? `Type: ${type}` : null,
            id !== null ? `ID: ${id}` : null
        ].filter(Boolean).join(" · ")

        textContainer.append(title, metadata)

        const actions = document.createElement("div")
        actions.className = "flex shrink-0 flex-wrap items-center gap-2"

        const detailsButton = document.createElement("button")
        detailsButton.type = "button"
        detailsButton.className =
            "rounded-lg border border-orange-200 bg-white px-3 py-2 " +
            "text-sm font-bold text-orange-800 hover:bg-orange-50 " +
            "focus:outline-none focus:ring-2 focus:ring-orange-300"

        detailsButton.textContent = "Details"
        detailsButton.setAttribute(
            "aria-label",
            `Show details for ${this.entityTitle(entity, index)}`
        )
        detailsButton.setAttribute("aria-haspopup", "dialog")
        detailsButton.setAttribute("aria-expanded", "false")

        // Open only when the Details button is hovered.
        detailsButton.addEventListener("mouseenter", () => {
            this.scheduleClose(false)
            this.showPopup(entity, detailsButton)
            detailsButton.setAttribute("aria-expanded", "true")
        })

        // Support keyboard users.
        detailsButton.addEventListener("focus", () => {
            this.showPopup(entity, detailsButton)
            detailsButton.setAttribute("aria-expanded", "true")
        })

        // Support touchscreens and click interaction.
        detailsButton.addEventListener("click", () => {
            if (this.activeCard === detailsButton && this.activePopup) {
                this.removePopup()
                detailsButton.setAttribute("aria-expanded", "false")
            } else {
                this.showPopup(entity, detailsButton)
                detailsButton.setAttribute("aria-expanded", "true")
            }
        })

        detailsButton.addEventListener("mouseleave", () => {
            this.scheduleClose(true)
        })

        detailsButton.addEventListener("blur", () => {
            this.scheduleClose(true)
        })

        actions.appendChild(detailsButton)

        const adminUrl = this.adminUrl(entity)

        if (adminUrl) {
            const adminLink = document.createElement("a")
            adminLink.href = adminUrl
            adminLink.className =
                "inline-flex items-center rounded-lg bg-orange-600 px-3 py-2 " +
                "text-sm font-bold text-white hover:bg-orange-700 " +
                "focus:outline-none focus:ring-2 focus:ring-orange-300"

            adminLink.textContent = "Open in admin"
            adminLink.setAttribute(
                "aria-label",
                `Open ${this.entityTitle(entity, index)} in admin`
            )

            actions.appendChild(adminLink)
        }

        heading.append(textContainer, actions)
        card.appendChild(heading)

        const description = this.firstValue(entity, [
            "summary",
            "description"
        ])

        if (description) {
            const summary = document.createElement("p")
            summary.className = "mt-3 text-sm leading-6 text-slate-600"
            summary.textContent = String(description)
            card.appendChild(summary)
        }

        const relationshipCount = this.relationshipsFor(entity).length

        const footer = document.createElement("p")
        footer.className = "mt-3 text-xs font-semibold text-slate-500"
        footer.textContent =
            `${relationshipCount} related ` +
            `${relationshipCount === 1 ? "relationship" : "relationships"} · ` +
            "Select Details to inspect"

        card.appendChild(footer)

        // Intentionally no mouseenter or click handler on the record itself.
        return card
    }

    showPopup(entity, anchor) {
        clearTimeout(this.closeTimer)
        this.removePopup()

        const popup = document.createElement("aside")

        popup.className =
            "fixed z-[9999] w-[min(420px,calc(100vw-24px))] " +
            "max-h-[min(70vh,560px)] overflow-y-auto rounded-2xl " +
            "border border-slate-200 bg-white p-5 shadow-2xl"

        popup.setAttribute("role", "dialog")
        popup.setAttribute("aria-label", `Details for ${this.entityTitle(entity, 0)}`)

        const header = document.createElement("div")
        header.className = "flex items-start justify-between gap-3"

        const heading = document.createElement("h3")
        heading.className = "break-words text-lg font-black text-slate-900"
        heading.textContent = this.entityTitle(entity, 0)

        const closeButton = document.createElement("button")
        closeButton.type = "button"
        closeButton.className =
            "shrink-0 rounded-lg border border-slate-200 px-3 py-1 " +
            "text-sm font-bold text-slate-700 hover:bg-slate-50"
        closeButton.textContent = "Close"
        closeButton.setAttribute("aria-label", "Close entity details")
        closeButton.addEventListener("click", () => this.removePopup())

        header.append(heading, closeButton)
        popup.appendChild(header)

        const description = this.firstValue(entity, [
            "summary",
            "description"
        ])

        if (description) {
            const paragraph = document.createElement("p")
            paragraph.className = "mt-3 text-sm leading-6 text-slate-600"
            paragraph.textContent = String(description)
            popup.appendChild(paragraph)
        }

        const detailsHeading = document.createElement("h4")
        detailsHeading.className =
            "mt-4 border-b border-slate-100 pb-2 text-xs font-black " +
            "uppercase tracking-wider text-slate-500"
        detailsHeading.textContent = "Entity attributes"
        popup.appendChild(detailsHeading)

        const excluded = new Set([
            "summary",
            "description",
            "created_at",
            "updated_at"
        ])

        const attributes = Object.entries(entity || {})
            .filter(([key, value]) =>
                !excluded.has(key) &&
                value !== null &&
                value !== undefined &&
                value !== ""
            )
            .slice(0, 40)

        const table = document.createElement("dl")
        table.className = "mt-2 space-y-2"

        attributes.forEach(([key, value]) => {
            const row = document.createElement("div")
            row.className =
                "grid grid-cols-[minmax(0,120px)_minmax(0,1fr)] gap-3 " +
                "border-b border-slate-50 py-1.5"

            const term = document.createElement("dt")
            term.className = "break-words text-xs font-bold text-slate-500"
            term.textContent = this.humanize(key)

            const definition = document.createElement("dd")
            definition.className = "break-words text-sm text-slate-800"
            definition.textContent = this.formatValue(value)

            row.append(term, definition)
            table.appendChild(row)
        })

        popup.appendChild(table)

        const related = this.relationshipsFor(entity)

        const relationshipsHeading = document.createElement("h4")
        relationshipsHeading.className =
            "mt-5 border-b border-slate-100 pb-2 text-xs font-black " +
            "uppercase tracking-wider text-slate-500"
        relationshipsHeading.textContent = `Relationships (${related.length})`
        popup.appendChild(relationshipsHeading)

        if (related.length === 0) {
            const none = document.createElement("p")
            none.className = "mt-3 text-sm text-slate-500"
            none.textContent = "No relationships are available for this entity in the current results."
            popup.appendChild(none)
        } else {
            const list = document.createElement("ul")
            list.className = "mt-2 space-y-2"

            related.slice(0, 30).forEach(relationship => {
                const item = document.createElement("li")
                item.className = "rounded-lg bg-slate-50 p-3"

                const label = this.firstValue(relationship, [
                    "label",
                    "relationship_type_name",
                    "relationship_type",
                    "relationship_kind",
                    "type",
                    "name"
                ])

                const text = document.createElement("p")
                text.className = "text-sm font-bold text-slate-800"
                text.textContent = String(label || "Relationship")

                const endpoints = document.createElement("p")
                endpoints.className = "mt-1 break-words text-xs text-slate-500"
                endpoints.textContent = this.relationshipEndpoints(relationship)

                item.append(text, endpoints)
                list.appendChild(item)
            })

            popup.appendChild(list)
        }

        const adminUrl = this.adminUrl(entity)

        if (adminUrl) {
            const link = document.createElement("a")
            link.href = adminUrl
            link.className =
                "mt-5 inline-flex w-full items-center justify-center rounded-xl " +
                "bg-orange-600 px-4 py-3 text-sm font-black text-white " +
                "hover:bg-orange-700 focus:outline-none focus:ring-4 focus:ring-orange-200"
            link.textContent = "Open entity in admin panel"
            popup.appendChild(link)
        }

        popup.addEventListener("mouseenter", () => {
            this.scheduleClose(false)
        })

        popup.addEventListener("mouseleave", () => {
            this.scheduleClose(true)
        })

        document.body.appendChild(popup)

        this.activeCard = anchor
        this.activePopup = popup

        this.positionPopup(anchor, popup)
    }

    positionPopup(anchor, popup) {
        const rect = anchor.getBoundingClientRect()
        const margin = 12

        // Measure after adding the popup to the document.
        const popupRect = popup.getBoundingClientRect()

        let left = rect.right + margin

        if (left + popupRect.width > window.innerWidth - margin) {
            left = rect.left - popupRect.width - margin
        }

        // If neither side has enough room, center the popup horizontally.
        if (left < margin) {
            left = Math.max(
                margin,
                (window.innerWidth - popupRect.width) / 2
            )
        }

        let top = rect.top

        if (top + popupRect.height > window.innerHeight - margin) {
            top = window.innerHeight - popupRect.height - margin
        }

        top = Math.max(margin, top)

        popup.style.left = `${left}px`
        popup.style.top = `${top}px`
    }

    scheduleClose(shouldClose) {
        clearTimeout(this.closeTimer)

        if (!shouldClose) return

        this.closeTimer = setTimeout(() => {
            const hovered = this.activePopup?.matches(":hover")
            const anchorHovered = this.activeCard?.matches(":hover")
            const focused = this.activePopup?.contains(document.activeElement)

            if (!hovered && !anchorHovered && !focused) {
                this.removePopup()
            }
        }, 250)
    }

    removePopup() {
        if (this.activePopup) {
            this.activePopup.remove()
        }

        this.activePopup = null
        this.activeCard = null
    }

    handleDocumentKeydown(event) {
        if (event.key === "Escape") {
            this.removePopup()
        }
    }

    relationshipsFor(entity) {
        const ids = [
            entity?.id,
            entity?.identifier,
            entity?.slug
        ]
            .filter(value => value !== null && value !== undefined)
            .map(String)

        return this.relationships.filter(relationship => {
            const source = String(
                relationship.source ??
                relationship.source_id ??
                relationship.source_entity_id ??
                relationship.from ??
                ""
            )

            const target = String(
                relationship.target ??
                relationship.target_id ??
                relationship.target_entity_id ??
                relationship.to ??
                ""
            )

            return ids.includes(source) || ids.includes(target)
        })
    }

    relationshipEndpoints(relationship) {
        const source =
            relationship.source ??
            relationship.source_id ??
            relationship.source_entity_id ??
            relationship.from

        const target =
            relationship.target ??
            relationship.target_id ??
            relationship.target_entity_id ??
            relationship.to

        const parts = []

        if (source !== undefined && source !== null) {
            parts.push(`From: ${source}`)
        }

        if (target !== undefined && target !== null) {
            parts.push(`To: ${target}`)
        }

        return parts.join(" · ") || "Endpoint details unavailable"
    }

    adminUrl(entity) {
        // Prefer an explicit admin/show URL returned by the server.
        const direct = entity?.admin_url ?? entity?.show_url

        if (typeof direct === "string" && direct.trim()) {
            try {
                const url = new URL(direct, window.location.origin)

                // Do not generate links to an external host.
                if (url.origin === window.location.origin) {
                    return url.href
                }
            } catch {
                return null
            }
        }

        // Otherwise use the configurable Rails route template.
        const id = entity?.id

        if (
            id === undefined ||
            id === null ||
            !this.hasAdminUrlTemplateValue ||
            !this.adminUrlTemplateValue
        ) {
            return null
        }

        const path = this.adminUrlTemplateValue.replace(
            ":id",
            encodeURIComponent(String(id))
        )

        try {
            const url = new URL(path, window.location.origin)

            if (url.origin !== window.location.origin) return null

            return url.href
        } catch {
            return null
        }
    }

    entityTitle(entity, index) {
        return String(
            this.firstValue(entity, [
                "name",
                "title",
                "label",
                "identifier",
                "slug",
                "id"
            ]) ?? `Entity ${index + 1}`
        )
    }

    firstValue(object, keys) {
        for (const key of keys) {
            const value = object?.[key]

            if (
                value !== undefined &&
                value !== null &&
                value !== ""
            ) {
                if (typeof value !== "object") return value

                if (Array.isArray(value)) {
                    return value.length ? value.join(", ") : null
                }

                return JSON.stringify(value)
            }
        }

        return null
    }

    formatValue(value) {
        if (typeof value === "object" && value !== null) {
            return JSON.stringify(value, null, 2)
        }

        return String(value)
    }

    humanize(key) {
        return String(key)
            .replace(/_/g, " ")
            .replace(/\b\w/g, letter => letter.toUpperCase())
    }

    clearList() {
        this.listTarget.replaceChildren()
        this.listTarget.classList.add("hidden")
    }

    showEmpty(message = "Enter a search above and select Search to display matching records here.") {
        this.clearList()
        this.removePopup()

        this.emptyTarget.classList.remove("hidden")

        const paragraph = this.emptyTarget.querySelector("p")

        if (paragraph) {
            paragraph.textContent = message
        }

        if (this.hasCountTarget) {
            this.countTarget.textContent = "No results"
        }

        if (this.hasErrorTarget) {
            this.errorTarget.classList.add("hidden")
            this.errorTarget.textContent = ""
        }
    }

    showError(message) {
        this.clearList()
        this.removePopup()

        this.emptyTarget.classList.add("hidden")

        if (this.hasErrorTarget) {
            this.errorTarget.textContent = String(message)
            this.errorTarget.classList.remove("hidden")
        }

        if (this.hasCountTarget) {
            this.countTarget.textContent = "Search error"
        }
    }
}