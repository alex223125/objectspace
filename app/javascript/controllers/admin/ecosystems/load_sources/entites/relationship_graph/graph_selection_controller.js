
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["dossier"];

    connect() {
        this.records = new Map();
        this.selectedId = null;
        this.registerExistingRecords();
    }

    disconnect() {
        this.records?.clear();
    }

    registerExistingRecords() {
        this.element.querySelectorAll("[data-entity-id]").forEach((element) => {
            const id = String(element.dataset.entityId || "");
            if (!id) return;

            this.records.set(id, {
                id,
                name: element.dataset.entityName || "",
                description: element.dataset.entityDescription || "",
                type: element.dataset.entityType || "",
                relationships: this.parseJSON(element.dataset.entityRelationships),
                attributes: this.parseJSON(element.dataset.entityAttributes),
            });
        });
    }

    parseJSON(value) {
        if (!value) return [];

        try {
            const parsed = JSON.parse(value);
            return Array.isArray(parsed) ? parsed : [];
        } catch {
            return [];
        }
    }

    select(event) {
        event?.preventDefault();

        // Inspect is inside the selectable article; don't let its click
        // trigger the article handler a second time.
        if (event?.currentTarget?.tagName === "BUTTON") {
            event.stopPropagation();
        }

        const trigger = event?.currentTarget;
        const article = trigger?.closest("[data-entity-id]");

        const id = String(
            event?.params?.id ??
            trigger?.dataset?.entityId ??
            article?.dataset?.entityId ??
            ""
        );

        if (!id) {
            console.error(
                "[GraphSelection] Cannot select record: no entity ID was found.",
                trigger
            );
            return;
        }

        const existing = this.records.get(id) || {};

        const record = {
            id,
            name:
                event?.params?.name ||
                trigger?.dataset?.entityName ||
                article?.dataset?.entityName ||
                existing.name ||
                article?.querySelector("h3")?.textContent?.trim() ||
                `Entity ${id}`,

            description:
                event?.params?.description ||
                trigger?.dataset?.entityDescription ||
                article?.dataset?.entityDescription ||
                existing.description ||
                "",

            type:
                event?.params?.type ||
                trigger?.dataset?.entityType ||
                article?.dataset?.entityType ||
                existing.type ||
                "",

            relationships:
                this.readArray(
                    trigger?.dataset?.entityRelationships,
                    article?.dataset?.entityRelationships,
                    existing.relationships
                ),

            attributes:
                this.readArray(
                    trigger?.dataset?.entityAttributes,
                    article?.dataset?.entityAttributes,
                    existing.attributes
                ),
        };

        this.records.set(id, record);
        this.selectedId = id;

        this.highlightSelection(id);
        this.renderDossier(record);

        this.dispatch("selected", { detail: { entity: record } });

        console.debug("[GraphSelection] Selected entity:", record);
    }

    readArray(triggerValue, articleValue, existingValue) {
        if (triggerValue) return this.parseJSON(triggerValue);
        if (articleValue) return this.parseJSON(articleValue);
        return Array.isArray(existingValue) ? existingValue : [];
    }

    renderDossier(record) {
        if (!this.hasDossierTarget) {
            console.error(
                "[GraphSelection] Missing dossier target. Ensure the directory " +
                "and dossier are inside the same data-controller=\"graph-selection\" scope."
            );
            return;
        }

        const dossier = this.dossierTarget;
        dossier.replaceChildren();

        const card = document.createElement("div");
        card.className =
            "rounded-2xl border-2 border-violet-200 bg-white p-5";

        const heading = document.createElement("h3");
        heading.className =
            "break-words text-xl font-black text-slate-900";
        heading.textContent = record.name || `Entity ${record.id}`;
        card.append(heading);

        const identifier = document.createElement("p");
        identifier.className = "mt-2 break-all text-sm text-slate-500";
        identifier.textContent = `Identifier: ${record.id}`;
        card.append(identifier);

        if (record.type) {
            const type = document.createElement("span");
            type.className =
                "mt-3 inline-flex rounded-full border border-violet-200 " +
                "bg-violet-50 px-3 py-1.5 text-sm font-bold text-violet-800";
            type.textContent = record.type;
            card.append(type);
        }

        const description = document.createElement("p");
        description.className =
            "mt-4 whitespace-pre-wrap break-words text-base leading-7 text-slate-700";
        description.textContent =
            record.description || "No description is available for this entity.";
        card.append(description);

        this.appendSection(card, "Attributes", record.attributes);
        this.appendSection(card, "Relationships", record.relationships);

        dossier.append(card);
    }

    appendSection(parent, title, values) {
        if (!Array.isArray(values) || values.length === 0) return;

        const section = document.createElement("section");
        section.className = "mt-5 border-t border-slate-200 pt-4";

        const heading = document.createElement("h4");
        heading.className = "font-bold text-slate-900";
        heading.textContent = title;

        const list = document.createElement("ul");
        list.className = "mt-2 space-y-2 text-sm text-slate-600";

        values.forEach((value) => {
            const item = document.createElement("li");
            item.className = "break-words";

            if (value && typeof value === "object") {
                item.textContent = Object.entries(value)
                    .map(([key, val]) => `${key}: ${String(val ?? "")}`)
                    .join(" · ");
            } else {
                item.textContent = String(value ?? "");
            }

            list.append(item);
        });

        section.append(heading, list);
        parent.append(section);
    }

    highlightSelection(id) {
        this.element.querySelectorAll("[data-entity-id]").forEach((element) => {
            const selected = String(element.dataset.entityId) === String(id);

            element.classList.toggle("ring-2", selected);
            element.classList.toggle("ring-violet-500", selected);
            element.classList.toggle("border-violet-400", selected);
            element.setAttribute("aria-selected", String(selected));
        });
    }
}