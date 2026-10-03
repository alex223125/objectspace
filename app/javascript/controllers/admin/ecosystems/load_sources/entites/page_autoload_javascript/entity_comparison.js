// ============================================================
// Entity Comparison
// ============================================================
//
// Page-level comparison behavior.
//
// Responsibilities:
//
// - Version-pair validation
// - Search comparison facts
// - Filter comparison facts by type
// - Reset filters
// - Maintain visible result counts
// - Work with Turbo navigation
//
// ============================================================

(() => {
  "use strict";

  const ROOT_SELECTOR = "[data-entity-comparison]";

  const SEARCH_SELECTOR =
      "[data-comparison-search]";

  const TYPE_FILTER_SELECTOR =
      "[data-comparison-type-filter]";

  const RESET_SELECTOR =
      "[data-comparison-reset]";

  const ROW_SELECTOR =
      "[data-comparison-row]";

  const VISIBLE_COUNT_SELECTOR =
      "[data-comparison-visible-count]";

  const TOTAL_COUNT_SELECTOR =
      "[data-comparison-total-count]";

  const EMPTY_SELECTOR =
      "[data-comparison-empty]";

  const NO_FACTS_SELECTOR =
      "[data-comparison-no-facts]";

  const FROM_VERSION_SELECTOR =
      "[data-comparison-from-version]";

  const TO_VERSION_SELECTOR =
      "[data-comparison-to-version]";

  const VERSION_FORM_SELECTOR =
      ".entity-comparison__version-form";

  const VERSION_ERROR_SELECTOR =
      "[data-comparison-version-error]";

  const INITIALIZED_ATTRIBUTE =
      "data-comparison-initialized";

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  function initialize(root) {
    if (!root) {
      return;
    }

    if (
        root.hasAttribute(
            INITIALIZED_ATTRIBUTE
        )
    ) {
      return;
    }

    root.setAttribute(
        INITIALIZED_ATTRIBUTE,
        "true"
    );

    initializeVersionSelector(root);
    initializeFilters(root);
  }

  // ==========================================================
  // VERSION SELECTOR
  // ==========================================================

  function initializeVersionSelector(root) {
    const form =
        root.querySelector(
            VERSION_FORM_SELECTOR
        );

    const fromVersion =
        root.querySelector(
            FROM_VERSION_SELECTOR
        );

    const toVersion =
        root.querySelector(
            TO_VERSION_SELECTOR
        );

    const error =
        root.querySelector(
            VERSION_ERROR_SELECTOR
        );

    if (!form) {
      return;
    }

    form.addEventListener(
        "submit",
        (event) => {
          const fromValue =
              fromVersion
                  ? fromVersion.value
                  : "";

          const toValue =
              toVersion
                  ? toVersion.value
                  : "";

          const invalid =
              !fromValue ||
              !toValue ||
              fromValue === toValue;

          if (!invalid) {
            if (error) {
              error.hidden = true;
            }

            return;
          }

          event.preventDefault();

          if (error) {
            error.hidden = false;
          }

          if (
              !fromValue &&
              fromVersion
          ) {
            fromVersion.focus();
          } else if (
              !toValue &&
              toVersion
          ) {
            toVersion.focus();
          } else if (toVersion) {
            toVersion.focus();
          }
        }
    );

    if (fromVersion) {
      fromVersion.addEventListener(
          "change",
          () => {
            if (error) {
              error.hidden = true;
            }
          }
      );
    }

    if (toVersion) {
      toVersion.addEventListener(
          "change",
          () => {
            if (error) {
              error.hidden = true;
            }
          }
      );
    }
  }

  // ==========================================================
  // FILTERS
  // ==========================================================

  function initializeFilters(root) {
    const searchInput =
        root.querySelector(
            SEARCH_SELECTOR
        );

    const typeFilter =
        root.querySelector(
            TYPE_FILTER_SELECTOR
        );

    const resetButton =
        root.querySelector(
            RESET_SELECTOR
        );

    const rows =
        Array.from(
            root.querySelectorAll(
                ROW_SELECTOR
            )
        );

    const visibleCount =
        root.querySelector(
            VISIBLE_COUNT_SELECTOR
        );

    const totalCount =
        root.querySelector(
            TOTAL_COUNT_SELECTOR
        );

    const emptyState =
        root.querySelector(
            EMPTY_SELECTOR
        );

    const noFactsState =
        root.querySelector(
            NO_FACTS_SELECTOR
        );

    if (totalCount) {
      totalCount.textContent =
          String(rows.length);
    }

    function update() {
      const searchTerm =
          normalize(
              searchInput
                  ? searchInput.value
                  : ""
          );

      const selectedType =
          typeFilter
              ? normalize(
                  typeFilter.value
              )
              : "all";

      let visibleRows = 0;

      rows.forEach((row) => {
        const rowType =
            normalize(
                row.dataset.changeType ||
                ""
            );

        const searchableText =
            buildSearchableText(row);

        const matchesSearch =
            searchTerm.length === 0 ||
            searchableText.includes(
                searchTerm
            );

        const matchesType =
            selectedType === "all" ||
            rowType === selectedType;

        const visible =
            matchesSearch &&
            matchesType;

        row.hidden = !visible;

        if (visible) {
          visibleRows += 1;
        }
      });

      if (visibleCount) {
        visibleCount.textContent =
            String(visibleRows);
      }

      if (emptyState) {
        emptyState.hidden =
            rows.length === 0 ||
            visibleRows > 0;
      }

      if (noFactsState) {
        noFactsState.hidden =
            rows.length > 0;
      }
    }

    function reset() {
      if (searchInput) {
        searchInput.value = "";
      }

      if (typeFilter) {
        typeFilter.value = "all";
      }

      update();

      if (searchInput) {
        searchInput.focus();
      }
    }

    if (searchInput) {
      searchInput.addEventListener(
          "input",
          update
      );

      searchInput.addEventListener(
          "search",
          update
      );
    }

    if (typeFilter) {
      typeFilter.addEventListener(
          "change",
          update
      );
    }

    if (resetButton) {
      resetButton.addEventListener(
          "click",
          reset
      );
    }

    update();
  }

  // ==========================================================
  // SEARCH TEXT
  // ==========================================================

  function buildSearchableText(row) {
    const values = [
      row.dataset.changeType,
      row.dataset.comparisonPath,
      row.dataset.comparisonIdentity,
      row.dataset.oldValue,
      row.dataset.newValue,
      row.textContent
    ];

    return normalize(
        values
            .filter(
                (value) =>
                    value !== null &&
                    value !== undefined
            )
            .join(" ")
    );
  }

  // ==========================================================
  // NORMALIZATION
  // ==========================================================

  function normalize(value) {
    return String(value || "")
        .trim()
        .toLowerCase();
  }

  // ==========================================================
  // ROOT DISCOVERY
  // ==========================================================

  function initializeAll() {
    const roots =
        document.querySelectorAll(
            ROOT_SELECTOR
        );

    roots.forEach(
        initialize
    );
  }

  // ==========================================================
  // TURBO
  // ==========================================================

  document.addEventListener(
      "DOMContentLoaded",
      initializeAll
  );

  document.addEventListener(
      "turbo:load",
      initializeAll
  );

  document.addEventListener(
      "turbo:frame-load",
      initializeAll
  );

  // ==========================================================
  // INITIAL EXECUTION
  // ==========================================================

  initializeAll();
})();