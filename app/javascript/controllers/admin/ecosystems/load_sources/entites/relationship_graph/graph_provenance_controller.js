
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["timeline", "emptyState", "count"];

    static values = {
        events: { type: Array, default: [] }
    };

    connect() {
        this.render();
    }

    eventsValueChanged() {
        this.render();
    }

    render() {
        const events = [...(this.eventsValue || [])].sort((a, b) => {
            return this.timestamp(b) - this.timestamp(a);
        });

        if (this.hasCountTarget) {
            this.countTarget.textContent = `${events.length} events`;
        }

        if (this.hasEmptyStateTarget) {
            this.emptyStateTarget.hidden = events.length > 0;
        }

        if (!this.hasTimelineTarget) return;

        this.timelineTarget.replaceChildren();

        events.forEach((event) => {
            const item = document.createElement("li");
            item.className = "relative border-l-2 border-orange-200 pb-6 pl-6";

            const marker = document.createElement("span");
            marker.className =
                "absolute -left-[7px] top-1 h-3 w-3 rounded-full " +
                "border-2 border-white bg-orange-400 ring-2 ring-orange-100";
            marker.setAttribute("aria-hidden", "true");

            const heading = document.createElement("h4");
            heading.className = "text-base font-bold text-slate-800";
            heading.textContent = event.action || event.event_type || "Graph event";

            const detail = document.createElement("p");
            detail.className = "mt-1 text-sm leading-6 text-slate-600";
            detail.textContent =
                event.description || event.summary || "No additional details.";

            const time = document.createElement("time");
            time.className = "mt-2 block text-xs font-semibold text-slate-500";

            const timestamp = this.timestamp(event);

            if (timestamp > 0) {
                time.dateTime = new Date(timestamp).toISOString();
                time.textContent = new Intl.DateTimeFormat(undefined, {
                    dateStyle: "medium",
                    timeStyle: "short"
                }).format(timestamp);
            } else {
                time.textContent = "Time unavailable";
            }

            item.append(marker, heading, detail, time);

            if (event.actor) {
                const actor = document.createElement("p");
                actor.className = "mt-2 text-xs font-medium text-violet-700";
                actor.textContent = `Actor: ${event.actor}`;
                item.appendChild(actor);
            }

            this.timelineTarget.appendChild(item);
        });
    }

    timestamp(event) {
        const raw = event.created_at || event.timestamp || event.updated_at;
        if (!raw) return 0;

        const parsed = Date.parse(raw);
        return Number.isFinite(parsed) ? parsed : 0;
    }

    setEvents(events) {
        if (!Array.isArray(events)) return;

        this.eventsValue = events;
    }
}