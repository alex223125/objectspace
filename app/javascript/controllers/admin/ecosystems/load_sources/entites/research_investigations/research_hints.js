(() => {
    const installResearchHints = () => {
        if (document.documentElement.dataset.researchHintsInstalled === "true") return;
        document.documentElement.dataset.researchHintsInstalled = "true";

const tooltip = document.createElement("div");
tooltip.id = "research-cursor-tooltip";
tooltip.setAttribute("role", "tooltip");
tooltip.setAttribute("aria-hidden", "true");
document.body.appendChild(tooltip);

let activeTrigger = null;

const hide = () => {
  activeTrigger = null;
  tooltip.classList.remove("is-visible");
  tooltip.setAttribute("aria-hidden", "true");
};

const move = (event) => {
  if (!activeTrigger) return;

  const offset = 16;
  const margin = 12;

  tooltip.style.left = `${Math.min(
            event.clientX + offset,
            window.innerWidth - tooltip.offsetWidth - margin
        )}px`;

  tooltip.style.top = `${Math.min(
            event.clientY + offset,
            window.innerHeight - tooltip.offsetHeight - margin
        )}px`;
};

document.addEventListener("pointerover", (event) => {
  const trigger = event.target.closest("[data-research-hint]");
  if (!trigger || trigger === activeTrigger) return;

  activeTrigger = trigger;
  tooltip.textContent = trigger.dataset.researchHint || "";
  tooltip.classList.add("is-visible");
  tooltip.setAttribute("aria-hidden", "false");
});

document.addEventListener("pointermove", move);

document.addEventListener("pointerout", (event) => {
  if (!activeTrigger) return;

  const next = event.relatedTarget;
  if (next && activeTrigger.contains(next)) return;
  if (next && next.closest && next.closest("[data-research-hint]") === activeTrigger) return;

  if (event.target === activeTrigger || activeTrigger.contains(event.target)) {
    hide();
  }
});

document.addEventListener("focusin", (event) => {
  const trigger = event.target.closest("[data-research-hint]");
  if (!trigger) return;

  activeTrigger = trigger;
  tooltip.textContent = trigger.dataset.researchHint || "";
  tooltip.classList.add("is-visible");
  tooltip.setAttribute("aria-hidden", "false");

  const rect = trigger.getBoundingClientRect();
  tooltip.style.left = `${Math.min(rect.left, window.innerWidth - tooltip.offsetWidth - 12)}px`;
  tooltip.style.top = `${Math.min(rect.bottom + 8, window.innerHeight - tooltip.offsetHeight - 12)}px`;
});

document.addEventListener("focusout", (event) => {
  if (event.target === activeTrigger) hide();
});

window.addEventListener("scroll", hide, { passive: true });

    };

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", installResearchHints, { once: true });
    } else {
        installResearchHints();
    }
})();
