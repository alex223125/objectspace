// app/javascript/admin/ecosystems/load_sources/entities/comparison.js
//
// Legacy compatibility entry point.
//
// The comparison UI is now owned by the Stimulus controller:
//
// entity_version_comparison_controller.js
//
// This file intentionally does not implement filtering itself.
// Keeping a second filtering implementation here would cause
// duplicate listeners and divergent behaviour.

(() => {
    "use strict"

    const ROOT_SELECTOR =
        "[data-entity-comparison]"

    function initializeAll() {
        document
            .querySelectorAll(ROOT_SELECTOR)
            .forEach((root) => {
                root.dataset.comparisonReady =
                    "true"
            })
    }

    if (
        document.readyState ===
        "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            initializeAll,
            { once: true }
        )
    } else {
        initializeAll()
    }

    document.addEventListener(
        "turbo:load",
        initializeAll
    )
})()