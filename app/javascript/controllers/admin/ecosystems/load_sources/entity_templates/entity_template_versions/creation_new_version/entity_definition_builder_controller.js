import { Controller } from "@hotwired/stimulus";

import {
    validateJSON,
    validateDefinition
} from "../../../../../../../libs/entity_definition_validator";

import {
    repairDefinition,
    stringifyDefinition
} from "../../../../../../../libs/entity_definition_repair";

export default class extends Controller {
    static targets = [
        "json",
        "jsonError",
        "jsonErrorMessage",
        "jsonRepairSummary",
        "jsonRepairMessage",
        "jsonRepairChanges",

        "fieldEditor",
        "fieldEditorTitle",
        "fieldName",
        "fieldLabel",
        "fieldType",
        "fieldDescription",
        "requiredIcon",
        "requiredLabel",
        "multipleIcon",
        "multipleLabel",
        "activeIcon",
        "activeLabel",

        "builder",

        "fieldCount",
        "syncBadge",
        "status",
        "statusDot",
        "activity",

        "sidebarStatus",
        "sidebarFieldCount",
        "sidebarRequiredCount",
        "sidebarActiveCount",
        "health",
        "healthBar",

        "xp",
        "progressLabel",
        "progressBar",

        "headerStatus",
        "headerStatusDot",

        "submit",
        "submitReadiness",

        "toast",
        "toastIcon",
        "toastTitle",
        "toastMessage",

        "missionFieldIcon",

        // Allows the library modal to be addressed directly
        // when it lives inside this Stimulus controller.
        "libraryModal"
    ];

    connect() {
        console.group("[entity-definition-builder] CONNECT DEBUG");

        console.log("controller connected:", this);
        console.log("controller element:", this.element);

        console.log(
            "element:",
            this.element?.tagName,
            this.element?.getAttribute("data-controller")
        );

        console.log(
            "has libraryModal target:",
            this.hasLibraryModalTarget
        );

        console.log(
            "libraryModalTarget:",
            this.hasLibraryModalTarget
                ? this.libraryModalTarget
                : null
        );

        console.log(
            "libraryModal descendants:",
            this.element?.querySelectorAll(
                '[data-entity-definition-builder-target~="libraryModal"]'
            )
        );

        console.log(
            "definition-library descendants:",
            this.element?.querySelectorAll(
                '[data-controller*="definition-library"]'
            )
        );

        console.groupEnd();

        this.editingFieldIndex = null;
        this.fieldRequired = false;
        this.fieldMultiple = false;
        this.fieldActive = true;

        this.repairPreview = null;
        this.lastValidation = null;
        this.toastTimeout = null;

        this.fields = [];

        this.initializeFromJSON();
    }

    // ============================================================
    // INITIALIZATION
    // ============================================================

    initializeFromJSON() {
        if (!this.hasJsonTarget) {
            return;
        }

        const result = validateJSON(
            this.jsonTarget.value
        );

        this.lastValidation = result;

        if (
            result.parseValid &&
            result.schemaValid
        ) {
            this.fields =
                result.definition.fields || [];

            this.renderBuilder();
            this.clearJSONError();
            this.updateStatus();

            return;
        }

        if (result.parseValid) {
            this.fields =
                Array.isArray(result.definition?.fields)
                    ? result.definition.fields
                    : [];

            this.renderBuilder();

            this.showValidationErrors(result);

            return;
        }

        this.fields = [];

        this.renderBuilder();

        this.showValidationErrors(result);
    }

    // ============================================================
    // JSON INPUT
    // ============================================================

    jsonChanged() {
        this.invalidateRepairPreview();

        if (!this.hasJsonTarget) {
            return;
        }

        const result = validateJSON(
            this.jsonTarget.value
        );

        this.lastValidation = result;

        if (
            result.parseValid &&
            result.schemaValid
        ) {
            this.fields =
                result.definition.fields || [];

            this.renderBuilder();

            this.clearJSONError();
            this.updateStatus();

            this.showToast(
                "DEFINITION UPDATED",
                "JSON is valid and synchronized.",
                "success"
            );

            this.dispatchDefinitionChanged();

            return;
        }

        if (result.parseValid) {
            this.fields =
                Array.isArray(result.definition?.fields)
                    ? result.definition.fields
                    : [];

            this.renderBuilder();

            this.showValidationErrors(result);

            return;
        }

        /*
         * The JSON cannot be parsed at all.
         *
         * We cannot safely determine the field inventory from
         * malformed JSON, so keep the existing fields instead of
         * destroying the visual builder.
         */
        this.showValidationErrors(result);
    }

    // ============================================================
    // FORMAT JSON
    // ============================================================

    formatJson(event) {
        if (event) {
            event.preventDefault();
        }

        if (!this.hasJsonTarget) {
            return;
        }

        const validation = validateJSON(
            this.jsonTarget.value
        );

        this.lastValidation = validation;

        // ----------------------------------------------------------
        // VALID JSON
        // ----------------------------------------------------------

        if (
            validation.parseValid &&
            validation.schemaValid
        ) {
            this.jsonTarget.value =
                stringifyDefinition(
                    validation.definition
                );

            this.fields =
                validation.definition.fields || [];

            this.renderBuilder();

            this.clearJSONError();
            this.updateStatus();

            this.showToast(
                "JSON FORMATTED",
                "The valid definition was formatted without changing its meaning.",
                "success"
            );

            this.dispatchDefinitionChanged();

            return;
        }

        // ----------------------------------------------------------
        // INVALID JSON SYNTAX
        // ----------------------------------------------------------

        if (!validation.parseValid) {
            this.showValidationErrors(
                validation,
                "JSON syntax must be fixed before the definition can be repaired automatically."
            );

            this.showToast(
                "JSON NEEDS ATTENTION",
                "The JSON syntax could not be parsed.",
                "error"
            );

            return;
        }

        // ----------------------------------------------------------
        // PARSED BUT SCHEMA INVALID
        // ----------------------------------------------------------

        this.createRepairPreview(
            validation.definition
        );

        this.showToast(
            "REPAIR PREVIEW READY",
            "Review the proposed changes before applying them.",
            "warning"
        );
    }

    // ============================================================
    // REPAIR PREVIEW
    // ============================================================

    createRepairPreview(definition) {
        const beforeValidation =
            validateDefinition(definition);

        const repair =
            repairDefinition(definition);

        const afterValidation =
            validateDefinition(
                repair.repairedDefinition
            );

        this.repairPreview = {
            ...repair,
            beforeValidation,
            afterValidation
        };

        this.renderRepairPreview();

        this.showValidationErrors(
            beforeValidation,
            null,
            true
        );
    }

    renderRepairPreview() {
        if (!this.repairPreview) {
            return;
        }

        const {
            changes,
            warnings,
            afterValidation
        } = this.repairPreview;

        if (
            this.hasJsonRepairSummaryTarget
        ) {
            this.jsonRepairSummaryTarget.classList.remove(
                "hidden"
            );
        }

        if (
            this.hasJsonRepairMessageTarget
        ) {
            if (changes.length === 0) {
                this.jsonRepairMessageTarget.textContent =
                    "No automatic changes are available.";
            } else {
                this.jsonRepairMessageTarget.textContent =
                    `${changes.length} proposed change${changes.length === 1 ? "" : "s"} found. Review them before applying the repair.`;
            }
        }

        if (
            this.hasJsonRepairChangesTarget
        ) {
            this.jsonRepairChangesTarget.innerHTML =
                "";

            if (warnings.length > 0) {
                const warning = document.createElement(
                    "div"
                );

                warning.className =
                    "rounded-xl border border-amber-300 bg-amber-50 p-4 text-sm text-amber-900";

                warning.innerHTML = `
<div class="font-black">
  ⚠ Review before applying
</div>

<div class="mt-1 leading-6">
  ${this.escapeHTML(
                    warnings.join(" ")
                )}
</div>
`;

                this.jsonRepairChangesTarget.appendChild(
                    warning
                );
            }

            if (changes.length === 0) {
                const empty =
                    document.createElement("div");

                empty.className =
                    "rounded-xl border border-slate-200 bg-slate-50 p-4 text-sm font-semibold text-slate-600";

                empty.textContent =
                    afterValidation.valid
                        ? "No repair is required."
                        : "The repair engine could not produce a valid definition automatically.";

                this.jsonRepairChangesTarget.appendChild(
                    empty
                );

                return;
            }

            changes.forEach((change) => {
                this.jsonRepairChangesTarget.appendChild(
                    this.buildRepairChangeRow(change)
                );
            });
        }
    }

    buildRepairChangeRow(change) {
        const wrapper =
            document.createElement("div");

        const destructiveClass =
            change.destructive
                ? "border-amber-300 bg-amber-50"
                : "border-slate-200 bg-white";

        wrapper.className =
            `rounded-xl border-2 ${destructiveClass} p-4`;

        const original =
            this.formatRepairValue(
                change.originalValue
            );

        const repaired =
            this.formatRepairValue(
                change.repairedValue
            );

        const warningBadge =
            change.destructive
                ? `
<span class="rounded-full border border-amber-300 bg-amber-100 px-2 py-1 text-[10px] font-black uppercase tracking-wider text-amber-800">
    Potentially destructive
</span>
`
                : `
<span class="rounded-full border border-emerald-200 bg-emerald-50 px-2 py-1 text-[10px] font-black uppercase tracking-wider text-emerald-700">
    Safe normalization
</span>
`;

        wrapper.innerHTML = `
<div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">

    <div class="min-w-0 flex-1">

    <div class="flex flex-wrap items-center gap-2">

    <span class="text-sm font-black text-slate-800">
    ${this.escapeHTML(change.field)}
</span>

${
            change.property
                ? `
            <span class="rounded-md bg-slate-100 px-2 py-1 font-mono text-[10px] font-bold uppercase text-slate-500">
              ${this.escapeHTML(change.property)}
            </span>
          `
                : ""
        }

${warningBadge}

</div>

<div class="mt-4 grid gap-3 md:grid-cols-2">

  <div class="rounded-lg border border-red-200 bg-red-50 p-3">
    <div class="text-[10px] font-black uppercase tracking-wider text-red-600">
      Original value
    </div>

    <div class="mt-1 break-words font-mono text-sm font-semibold text-red-900">
      ${this.escapeHTML(original)}
    </div>
  </div>

  <div class="rounded-lg border border-emerald-200 bg-emerald-50 p-3">
    <div class="text-[10px] font-black uppercase tracking-wider text-emerald-600">
      Repaired value
    </div>

    <div class="mt-1 break-words font-mono text-sm font-semibold text-emerald-900">
      ${this.escapeHTML(repaired)}
    </div>
  </div>

</div>

<div class="mt-3 rounded-lg border border-slate-200 bg-slate-50 p-3">

  <div class="text-[10px] font-black uppercase tracking-wider text-slate-500">
    Reason
  </div>

  <div class="mt-1 text-sm leading-6 text-slate-700">
    ${this.escapeHTML(change.reason)}
  </div>

</div>

</div>

</div>
`;

        return wrapper;
    }

    formatRepairValue(value) {
        if (value === undefined) {
            return "(missing)";
        }

        if (value === null) {
            return "null";
        }

        if (typeof value === "object") {
            try {
                return JSON.stringify(value);
            } catch {
                return String(value);
            }
        }

        return String(value);
    }

    // ============================================================
    // APPLY REPAIR
    // ============================================================

    applyRepair(event) {
        if (event) {
            event.preventDefault();
        }

        if (!this.repairPreview) {
            if (this.hasJsonTarget) {
                const validation =
                    validateJSON(
                        this.jsonTarget.value
                    );

                if (
                    validation.parseValid &&
                    !validation.schemaValid
                ) {
                    this.createRepairPreview(
                        validation.definition
                    );
                }
            }

            return;
        }

        const preview =
            this.repairPreview;

        const currentValidation =
            validateJSON(
                this.jsonTarget.value
            );

        if (
            !currentValidation.parseValid ||
            !this.sameDefinition(
                currentValidation.definition,
                preview.original
            )
        ) {
            this.repairPreview = null;

            this.showToast(
                "PREVIEW EXPIRED",
                "The JSON changed after the preview was created. Generate a new repair preview.",
                "warning"
            );

            this.showValidationErrors(
                currentValidation
            );

            return;
        }

        if (
            !preview.afterValidation.valid
        ) {
            this.showToast(
                "REPAIR NOT SAFE TO APPLY",
                "The proposed repaired definition still has validation errors.",
                "error"
            );

            this.showValidationErrors(
                preview.afterValidation
            );

            return;
        }

        this.jsonTarget.value =
            stringifyDefinition(
                preview.repairedDefinition
            );

        const finalValidation =
            validateJSON(
                this.jsonTarget.value
            );

        this.lastValidation =
            finalValidation;

        if (
            !finalValidation.parseValid ||
            !finalValidation.schemaValid
        ) {
            this.jsonTarget.value =
                stringifyDefinition(
                    preview.original
                );

            this.showValidationErrors(
                finalValidation
            );

            this.showToast(
                "REPAIR REJECTED",
                "The repaired JSON failed final validation and was not kept.",
                "error"
            );

            this.repairPreview = null;

            return;
        }

        this.fields =
            finalValidation.definition.fields || [];

        this.renderBuilder();

        this.renderRepairSuccess(
            preview,
            finalValidation
        );

        this.updateStatus();

        this.showToast(
            "REPAIR APPLIED",
            `${preview.changes.length} change${preview.changes.length === 1 ? "" : "s"} applied and validated successfully.`,
            "success"
        );

        this.dispatchDefinitionChanged();
    }

    renderRepairSuccess(
        preview,
        finalValidation
    ) {
        if (
            this.hasJsonRepairSummaryTarget
        ) {
            this.jsonRepairSummaryTarget.classList.remove(
                "hidden"
            );

            this.jsonRepairSummaryTarget.classList.remove(
                "border-amber-400",
                "bg-amber-50"
            );

            this.jsonRepairSummaryTarget.classList.add(
                "border-emerald-300",
                "bg-emerald-50"
            );
        }

        if (
            this.hasJsonRepairMessageTarget
        ) {
            this.jsonRepairMessageTarget.className =
                "mt-1 text-sm leading-6 text-emerald-800";

            this.jsonRepairMessageTarget.textContent =
                `Repair applied successfully. ${preview.changes.length} change${preview.changes.length === 1 ? "" : "s"} made. Final validation passed. The visual builder is synchronized.`;
        }

        if (
            this.hasJsonRepairChangesTarget
        ) {
            this.jsonRepairChangesTarget.innerHTML =
                "";

            preview.changes.forEach(
                (change) => {
                    const row =
                        this.buildRepairChangeRow(
                            change
                        );

                    row.classList.add(
                        "border-emerald-200"
                    );

                    this.jsonRepairChangesTarget.appendChild(
                        row
                    );
                }
            );

            const success =
                document.createElement("div");

            success.className =
                "rounded-xl border-2 border-emerald-300 bg-emerald-50 p-4";

            success.innerHTML = `
<div class="flex items-start gap-3">

    <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-emerald-500 text-white">
    ✓
</div>

<div>

  <div class="text-sm font-black text-emerald-900">
    Repair complete
  </div>

  <div class="mt-1 text-sm leading-6 text-emerald-800">
    The repaired definition passed JSON and structure validation.
    The visual builder has been synchronized with the repaired definition.
  </div>

</div>

</div>
`;

            this.jsonRepairChangesTarget.prepend(
                success
            );
        }

        this.repairPreview = null;
    }

    // ============================================================
    // VALIDATION ERROR UI
    // ============================================================

    showValidationErrors(
        validation,
        customExplanation = null,
        keepRepairPreview = false
    ) {
        if (!this.hasJsonErrorTarget) {
            return;
        }

        this.jsonErrorTarget.classList.remove(
            "hidden"
        );

        const errors =
            validation.errors || [];

        const warnings =
            validation.warnings || [];

        const totalProblems =
            errors.length + warnings.length;

        if (
            this.hasJsonErrorMessageTarget
        ) {
            const explanation =
                customExplanation ||
                this.buildHumanExplanation(
                    validation
                );

            this.jsonErrorMessageTarget.innerHTML =
                this.buildReadableProblemContent(
                    validation,
                    explanation
                );
        }

        this.renderRepairControls(
            validation
        );

        if (
            !keepRepairPreview &&
            this.hasJsonRepairSummaryTarget
        ) {
            this.jsonRepairSummaryTarget.classList.add(
                "hidden"
            );
        }

        this.setStatusError(
            totalProblems
        );
    }

    buildHumanExplanation(
        validation
    ) {
        if (!validation.parseValid) {
            return "The text in the JSON editor is not valid JSON yet. Automatic structural repair can only run after the JSON can be parsed.";
        }

        if (
            validation.errorCount === 0 &&
            validation.warningCount > 0
        ) {
            return "The definition can be parsed and has no blocking errors, but some optional properties should be normalized.";
        }

        if (
            validation.errors.some(
                (problem) =>
                    problem.code ===
                    "invalid_name"
            )
        ) {
            return "One or more field names do not follow the builder naming rules. Names are normalized conservatively while labels and other field information are preserved.";
        }

        if (
            validation.errors.some(
                (problem) =>
                    problem.code ===
                    "duplicate_name"
            )
        ) {
            return "Two or more fields use the same name. Duplicate names are resolved deterministically using _2, _3 and so on.";
        }

        if (
            validation.errors.some(
                (problem) =>
                    problem.code ===
                    "unsupported_type" ||
                    problem.code ===
                    "invalid_type"
            )
        ) {
            return "One or more fields use a type that the definition builder does not support. The repair engine can use a safe fallback when necessary.";
        }

        return "The JSON is readable, but its structure does not currently match the definition builder schema. Review the proposed repair before applying it.";
    }




buildReadableProblemContent(
    validation,
    explanation
) {
  const errors =
      validation.errors || [];

  const warnings =
      validation.warnings || [];

  const problemCount =
      errors.length + warnings.length;

  const countLabel =
      problemCount === 1
          ? "1 issue found"
          : `${problemCount} issues found`;

  const problemRows =
      [...errors, ...warnings]
          .slice(0, 20)
          .map((problem) => {
            return this.buildUserFriendlyProblemRow(
                problem
            );
          })
          .join("");

  return `
<div class="space-y-5">

    <div class="flex flex-wrap items-center gap-3">

    <span class="inline-flex items-center rounded-full bg-red-600 px-3 py-1.5 text-xs font-black uppercase tracking-wider text-white">
    ${this.escapeHTML(countLabel)}
</span>

${
    validation.warningCount > 0
        ? `
        <span class="inline-flex items-center rounded-full border border-amber-300 bg-amber-50 px-3 py-1.5 text-xs font-black uppercase tracking-wider text-amber-800">
          ${validation.warningCount}
          warning${validation.warningCount === 1 ? "" : "s"}
        </span>
      `
        : ""
}

</div>

<div>

    <div class="text-base font-black text-slate-900">
        What needs attention?
    </div>

    <div class="mt-2 text-sm leading-6 text-slate-600">
        ${this.escapeHTML(explanation)}
    </div>

</div>

${
    problemRows
        ? `
      <div class="space-y-3">
        ${problemRows}
      </div>
    `
        : ""
}

${
    errors.length > 20
        ? `
      <div class="rounded-xl border border-slate-200 bg-slate-50 p-4 text-xs font-semibold leading-5 text-slate-600">
        Showing the first 20 issues. The repair preview will show the complete set of proposed changes.
      </div>
    `
        : ""
}

</div>
`;
}

buildUserFriendlyProblemRow(problem) {
  const details =
      this.describeValidationProblem(
          problem
      );

  const isWarning =
      problem.severity === "warning";

  const containerClass =
      isWarning
          ? "border-amber-200 bg-amber-50"
          : "border-red-200 bg-red-50";

  const iconClass =
      isWarning
          ? "bg-amber-100 text-amber-700"
          : "bg-red-100 text-red-700";

  const titleClass =
      isWarning
          ? "text-amber-950"
          : "text-red-950";

  const bodyClass =
      isWarning
          ? "text-amber-900"
          : "text-red-900";

  return `
<div class="rounded-2xl border-2 ${containerClass} p-4">

    <div class="flex items-start gap-3">

    <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl ${iconClass} text-sm font-black">
    ${isWarning ? "!" : "!"}
</div>

<div class="min-w-0 flex-1">

    <div class="text-sm font-black ${titleClass}">
        ${this.escapeHTML(details.title)}
    </div>

    <div class="mt-2 text-sm leading-6 ${bodyClass}">
        ${this.escapeHTML(details.message)}
    </div>

    ${
    details.action
        ? `
          <div class="mt-3 rounded-xl border border-white/70 bg-white/70 p-3">

            <div class="text-[10px] font-black uppercase tracking-wider ${bodyClass}">
              What will happen
            </div>

            <div class="mt-1 text-sm leading-5 ${bodyClass}">
              ${this.escapeHTML(details.action)}
            </div>

          </div>
        `
        : ""
}

    ${
    details.technical
        ? `
          <details class="mt-3">
            <summary class="cursor-pointer text-[10px] font-bold uppercase tracking-wider text-slate-500">
              Technical details
            </summary>

            <div class="mt-2 rounded-lg bg-slate-900 p-3 font-mono text-[11px] leading-5 text-slate-300">
              ${this.escapeHTML(details.technical)}
            </div>
          </details>
        `
        : ""
}

</div>

</div>

</div>
`;
}

describeValidationProblem(problem) {
  const path =
      String(problem.path || "");

  const message =
      String(problem.message || "");

  const code =
      String(problem.code || "");

  const fieldIndex =
      this.extractFieldIndex(path);

  const fieldNumber =
      fieldIndex !== null
          ? fieldIndex + 1
          : null;

  const fieldLabel =
      fieldIndex !== null
          ? this.getFieldDisplayName(
              fieldIndex
          )
          : null;

  // ------------------------------------------------------------
  // INVALID FIELD NAME
  // ------------------------------------------------------------

  if (
      code === "invalid_name" ||
      path.endsWith(".name") &&
      message.toLowerCase().includes(
          "must contain only letters"
      )
  ) {
    const currentName =
        fieldIndex !== null
            ? this.fields[fieldIndex]?.name
            : null;

    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Field name needs to be changed`
              : "Field name needs to be changed",

      message:
          currentName
              ? `The field is currently named "${currentName}". Field names can only use letters, numbers, and underscores, and they cannot begin with a number.`
              : "This field has a name that does not follow the naming rules. Field names can only use letters, numbers, and underscores, and they cannot begin with a number.",

      action:
          "The repair tool can create a valid field name while keeping the field's label, description, and other information.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // DUPLICATE FIELD NAME
  // ------------------------------------------------------------

  if (
      code === "duplicate_name"
  ) {
    const currentName =
        fieldIndex !== null
            ? this.fields[fieldIndex]?.name
            : null;

    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Duplicate field name`
              : "Duplicate field name",

      message:
          currentName
              ? `The field name "${currentName}" is already being used by another field. Each field must have its own unique name.`
              : "This field uses the same name as another field. Each field must have its own unique name.",

      action:
          "The repair tool will keep the first occurrence and give later fields a unique name such as _2, _3, and so on.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // UNSUPPORTED TYPE
  // ------------------------------------------------------------

  if (
      code === "unsupported_type" ||
      code === "invalid_type"
  ) {
    const typeMatch =
        message.match(
            /type\s+"([^"]+)"/i
        );

    const unsupportedType =
        typeMatch
            ? typeMatch[1]
            : fieldIndex !== null
                ? this.fields[fieldIndex]?.type
                : null;

    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Field type is not supported`
              : "Field type is not supported",

      message:
          unsupportedType
              ? `This field is configured as "${unsupportedType}", but this builder does not support that type.`
              : "This field uses a type that this builder does not support.",

      action:
          "The repair tool will replace the unsupported type with a supported type when a safe fallback is available. You can review the proposed replacement before applying it.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // MISSING MULTIPLE
  // ------------------------------------------------------------

  if (
      path.endsWith(".multiple") &&
      (
          message.toLowerCase().includes("missing") ||
          code === "missing_property"
      )
  ) {
    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Single or multiple value setting is missing`
              : "Single or multiple value setting is missing",

      message:
          fieldLabel
              ? `"${fieldLabel}" does not specify whether it accepts one value or multiple values.`
              : "This field does not specify whether it accepts one value or multiple values.",

      action:
          "The repair tool will set the field to Single value by default (multiple = false). If this field should accept multiple values, you can change that setting in the field editor afterward.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // MISSING REQUIRED
  // ------------------------------------------------------------

  if (
      path.endsWith(".required") &&
      (
          message.toLowerCase().includes("missing") ||
          code === "missing_property"
      )
  ) {
    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Required setting is missing`
              : "Required setting is missing",

      message:
          fieldLabel
              ? `"${fieldLabel}" does not specify whether the field is required.`
              : "This field does not specify whether the field is required.",

      action:
          "The repair tool will use the builder's default setting. You can change Required or Optional from the field editor.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // MISSING ACTIVE
  // ------------------------------------------------------------

  if (
      path.endsWith(".active") &&
      (
          message.toLowerCase().includes("missing") ||
          code === "missing_property"
      )
  ) {
    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Active status is missing`
              : "Active status is missing",

      message:
          fieldLabel
              ? `"${fieldLabel}" does not specify whether the field is active.`
              : "This field does not specify whether the field is active.",

      action:
          "The repair tool will use the builder's default active setting. You can enable or disable the field from the field editor.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // MISSING FIELD PROPERTY
  // ------------------------------------------------------------

  if (
      path.match(/^fields\[\d+\]\./) &&
      (
          message.toLowerCase().includes("missing") ||
          code === "missing_property"
      )
  ) {
    const property =
        path.split(".").pop();

    const readableProperty =
        this.humanizePropertyName(
            property
        );

    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — ${readableProperty} is missing`
              : `${readableProperty} is missing`,

      message:
          fieldLabel
              ? `"${fieldLabel}" does not contain a ${readableProperty.toLowerCase()} setting.`
              : `This field does not contain a ${readableProperty.toLowerCase()} setting.`,

      action:
          "The repair tool can add the missing setting using the definition builder's default value.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // EMPTY / INVALID LABEL
  // ------------------------------------------------------------

  if (
      path.endsWith(".label") &&
      (
          code === "invalid_label" ||
          message.toLowerCase().includes("label")
      )
  ) {
    return {
      title:
          fieldNumber !== null
              ? `Field ${fieldNumber} — Field label needs attention`
              : "Field label needs attention",

      message:
          "This field's display label is missing or does not have the expected format.",

      action:
          "The field label can be corrected without changing the underlying field name.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // GENERIC FIELD ERROR
  // ------------------------------------------------------------

  if (
      fieldNumber !== null
  ) {
    return {
      title:
          `Field ${fieldNumber} — Definition setting needs attention`,

      message:
          fieldLabel
              ? `"${fieldLabel}" has a configuration problem that needs to be corrected before this definition can be submitted.`
              : "This field has a configuration problem that needs to be corrected before this definition can be submitted.",

      action:
          "Review the proposed repair below. The technical validation details are available only if you expand the Technical details section.",

      technical:
          `${path}: ${message}`
    };
  }

  // ------------------------------------------------------------
  // GENERIC DEFINITION ERROR
  // ------------------------------------------------------------

  return {
    title:
        "Definition configuration needs attention",

    message:
        "The definition contains a configuration problem that prevents it from being fully validated.",

    action:
        "Review the repair suggestions below before applying them.",

    technical:
        `${path || "Definition"}: ${message}`
  };
}

extractFieldIndex(path) {
  const match =
      String(path || "").match(
          /^fields\[(\d+)\]/
      );

  if (!match) {
    return null;
  }

  return Number(match[1]);
}

getFieldDisplayName(index) {
  const field =
      this.fields[index];

  if (!field) {
    return null;
  }

  return (
      field.label ||
      field.name ||
      `Field ${index + 1}`
  );
}

humanizePropertyName(property) {
  const names = {
    name: "Field name",
    label: "Field label",
    type: "Field type",
    description: "Description",
    required: "Required setting",
    multiple: "Multiple value setting",
    active: "Active status"
  };

  return (
      names[property] ||
      String(property || "Property")
          .replaceAll("_", " ")
          .replace(
              /\b\w/g,
              (character) =>
                  character.toUpperCase()
          )
  );
}


















renderRepairControls(
        validation
    ) {
        const existing =
            this.jsonErrorTarget.querySelector(
                "[data-repair-actions]"
            );

        if (existing) {
            existing.remove();
        }

        const actions =
            document.createElement("div");

        actions.setAttribute(
            "data-repair-actions",
            "true"
        );

        actions.className =
            "mt-5 flex flex-col gap-3 border-t border-slate-200 pt-5 sm:flex-row sm:flex-wrap";

        const canRepair =
            validation.parseValid &&
            !validation.schemaValid;

        const repairButton =
            document.createElement("button");

        repairButton.type = "button";

        repairButton.className =
            "inline-flex items-center justify-center rounded-xl bg-violet-600 px-5 py-3 text-xs font-black uppercase tracking-wider text-white shadow-sm transition hover:bg-violet-700 disabled:cursor-not-allowed disabled:opacity-50";

        repairButton.textContent =
            "Auto Repair";

        repairButton.disabled =
            !canRepair;

        repairButton.addEventListener(
            "click",
            () => {
                if (
                    validation.parseValid
                ) {
                    this.createRepairPreview(
                        validation.definition
                    );
                }
            }
        );

        const formatButton =
            document.createElement("button");

        formatButton.type = "button";

        formatButton.className =
            "inline-flex items-center justify-center rounded-xl border-2 border-slate-300 bg-white px-5 py-3 text-xs font-black uppercase tracking-wider text-slate-700 transition hover:border-slate-400 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50";

        formatButton.textContent =
            "Format Only";

        formatButton.disabled =
            !validation.parseValid;

        formatButton.addEventListener(
            "click",
            () => {
                if (
                    validation.parseValid
                ) {
                    this.jsonTarget.value =
                        stringifyDefinition(
                            validation.definition
                        );

                    this.showToast(
                        "FORMATTED",
                        "Formatting completed without structural repair.",
                        "success"
                    );
                }
            }
        );

        actions.appendChild(
            repairButton
        );

        actions.appendChild(
            formatButton
        );

        if (this.repairPreview) {
            const applyButton =
                document.createElement(
                    "button"
                );

            applyButton.type = "button";

            applyButton.className =
                "inline-flex items-center justify-center rounded-xl bg-emerald-600 px-5 py-3 text-xs font-black uppercase tracking-wider text-white shadow-sm transition hover:bg-emerald-700";

            applyButton.textContent =
                "Apply Repair";

            applyButton.addEventListener(
                "click",
                (event) => {
                    this.applyRepair(event);
                }
            );

            actions.appendChild(
                applyButton
            );
        }

        this.jsonErrorTarget.appendChild(
            actions
        );
    }

    clearJSONError() {
        if (!this.hasJsonErrorTarget) {
            return;
        }

        this.jsonErrorTarget.classList.add(
            "hidden"
        );

        if (
            this.hasJsonRepairSummaryTarget
        ) {
            this.jsonRepairSummaryTarget.classList.add(
                "hidden"
            );
        }

        const actions =
            this.jsonErrorTarget.querySelector(
                "[data-repair-actions]"
            );

        if (actions) {
            actions.remove();
        }
    }

    invalidateRepairPreview() {
        this.repairPreview = null;

        if (
            this.hasJsonRepairSummaryTarget
        ) {
            this.jsonRepairSummaryTarget.classList.add(
                "hidden"
            );
        }
    }

    // ============================================================
    // BUILDER SYNCHRONIZATION
    // ============================================================

    renderBuilder() {
        if (!this.hasBuilderTarget) {
            return;
        }

        this.builderTarget.innerHTML = "";

        this.fields.forEach(
            (field, index) => {
                this.builderTarget.appendChild(
                    this.buildFieldCard(
                        field,
                        index
                    )
                );
            }
        );

        this.updateCounts();
    }

    updateCounts() {
        const fieldCount =
            this.fields.length;

        const requiredCount =
            this.fields.filter(
                (field) =>
                    field.required === true
            ).length;

        const activeCount =
            this.fields.filter(
                (field) =>
                    field.active !== false
            ).length;

        if (this.hasFieldCountTarget) {
            this.fieldCountTarget.textContent =
                `${fieldCount} FIELD${fieldCount === 1 ? "" : "S"}`;
        }

        if (this.hasSidebarFieldCountTarget) {
            this.sidebarFieldCountTarget.textContent =
                fieldCount;
        }

        if (this.hasSidebarRequiredCountTarget) {
            this.sidebarRequiredCountTarget.textContent =
                requiredCount;
        }

        if (this.hasSidebarActiveCountTarget) {
            this.sidebarActiveCountTarget.textContent =
                activeCount;
        }
    }

    buildFieldCard(field, index) {
        const card =
            document.createElement("div");

        card.className =
            "group rounded-2xl border-2 border-slate-100 bg-white p-4 shadow-sm transition hover:border-violet-200 hover:shadow-md";

        const typeLabel =
            field.type || "string";

        const required =
            field.required === true;

        const multiple =
            field.multiple === true;

        const active =
            field.active !== false;

        card.innerHTML = `
<div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">

    <div class="min-w-0 flex-1">

    <div class="flex flex-wrap items-center gap-2">

    <span class="font-mono text-sm font-black text-slate-800">
    ${this.escapeHTML(field.name || "")}
</span>

<span class="rounded-full bg-violet-50 px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-violet-600">
        ${this.escapeHTML(typeLabel)}
      </span>

${
            required
                ? `
            <span class="rounded-full bg-orange-50 px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-orange-600">
              REQUIRED
            </span>
          `
                : ""
        }

${
            multiple
                ? `
            <span class="rounded-full bg-sky-50 px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-sky-600">
              MULTIPLE
            </span>
          `
                : ""
        }

${
            active
                ? `
            <span class="rounded-full bg-emerald-50 px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-emerald-600">
              ACTIVE
            </span>
          `
                : `
            <span class="rounded-full bg-slate-100 px-2.5 py-1 text-[10px] font-black uppercase tracking-wider text-slate-500">
              INACTIVE
            </span>
          `
        }

</div>

<div class="mt-2 text-sm font-bold text-slate-700">
  ${this.escapeHTML(field.label || "")}
</div>

${
            field.description
                ? `
          <div class="mt-1 text-xs leading-5 text-slate-500">
            ${this.escapeHTML(field.description)}
          </div>
        `
                : ""
        }

</div>

<div class="flex shrink-0 items-center gap-2">

  <button
      type="button"
      class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-black uppercase tracking-wider text-slate-500 transition hover:border-violet-300 hover:text-violet-600"
      data-edit-field="${index}">
    Edit
  </button>

  <button
      type="button"
      class="rounded-xl border border-red-200 bg-red-50 px-3 py-2 text-xs font-black uppercase tracking-wider text-red-600 transition hover:border-red-300 hover:bg-red-100"
      data-delete-field="${index}">
    Delete
  </button>

</div>

</div>
`;

        const editButton =
            card.querySelector(
                "[data-edit-field]"
            );

        editButton?.addEventListener(
            "click",
            () => {
                this.openFieldEditor(
                    null,
                    index
                );
            }
        );

        const deleteButton =
            card.querySelector(
                "[data-delete-field]"
            );

        deleteButton?.addEventListener(
            "click",
            () => {
                this.deleteField(index);
            }
        );

        return card;
    }

    dispatchDefinitionChanged() {
        this.element.dispatchEvent(
            new CustomEvent(
                "entity-definition-builder:changed",
                {
                    bubbles: true,
                    detail: {
                        definition: {
                            fields: this.fields
                        }
                    }
                }
            )
        );
    }

    // ============================================================
    // FIELD EDITOR
    // ============================================================

    openFieldEditor(
        event,
        index = null
    ) {
        if (event) {
            event.preventDefault();
        }

        this.editingFieldIndex = index;

        if (
            index !== null &&
            this.fields[index]
        ) {
            const field =
                this.fields[index];

            this.fieldNameTarget.value =
                field.name || "";

            this.fieldLabelTarget.value =
                field.label || "";

            this.fieldTypeTarget.value =
                field.type || "string";

            this.fieldDescriptionTarget.value =
                field.description || "";

            this.fieldRequired =
                field.required === true;

            this.fieldMultiple =
                field.multiple === true;

            this.fieldActive =
                field.active !== false;

            if (
                this.hasFieldEditorTitleTarget
            ) {
                this.fieldEditorTitleTarget.textContent =
                    "Edit definition field";
            }
        } else {
            this.fieldNameTarget.value =
                "";

            this.fieldLabelTarget.value =
                "";

            this.fieldTypeTarget.value =
                "string";

            this.fieldDescriptionTarget.value =
                "";

            this.fieldRequired =
                false;

            this.fieldMultiple =
                false;

            this.fieldActive =
                true;

            if (
                this.hasFieldEditorTitleTarget
            ) {
                this.fieldEditorTitleTarget.textContent =
                    "Add definition field";
            }
        }

        this.updateFieldToggleUI();

        this.fieldEditorTarget.classList.remove(
            "hidden"
        );
    }

    closeFieldEditor(event) {
        if (event) {
            event.preventDefault();
        }

        this.fieldEditorTarget.classList.add(
            "hidden"
        );

        this.editingFieldIndex = null;
    }

    saveField(event) {
        if (event) {
            event.preventDefault();
        }

        const label =
            this.fieldLabelTarget.value.trim();

        const name =
            this.fieldNameTarget.value.trim();

        if (!name) {
            this.showToast(
                "FIELD NAME REQUIRED",
                "Enter a field name before saving.",
                "error"
            );

            this.fieldNameTarget.focus();

            return;
        }

        const field = {
            name,
            label: label || name,
            type:
                this.fieldTypeTarget.value ||
                "string",
            description:
                this.fieldDescriptionTarget.value.trim(),
            required:
            this.fieldRequired,
            multiple:
            this.fieldMultiple,
            active:
            this.fieldActive
        };

        if (
            this.editingFieldIndex !== null
        ) {
            this.fields[
                this.editingFieldIndex
                ] = field;
        } else {
            this.fields.push(field);
        }

        this.syncFieldsToJSON();

        this.closeFieldEditor();

        this.showToast(
            "FIELD SAVED",
            "The field was added to the definition.",
            "success"
        );
    }

    deleteField(index) {
        if (!this.fields[index]) {
            return;
        }

        const field =
            this.fields[index];

        const confirmed =
            window.confirm(
                `Delete field "${field.label || field.name}"?`
            );

        if (!confirmed) {
            return;
        }

        this.fields.splice(
            index,
            1
        );

        this.syncFieldsToJSON();

        this.showToast(
            "FIELD DELETED",
            "The field was removed from the definition.",
            "success"
        );
    }

    toggleFieldRequired() {
        this.fieldRequired =
            !this.fieldRequired;

        this.updateFieldToggleUI();
    }

    toggleFieldMultiple() {
        this.fieldMultiple =
            !this.fieldMultiple;

        this.updateFieldToggleUI();
    }

    toggleFieldActive() {
        this.fieldActive =
            !this.fieldActive;

        this.updateFieldToggleUI();
    }

    updateFieldToggleUI() {
        if (
            this.hasRequiredIconTarget
        ) {
            this.requiredIconTarget.textContent =
                this.fieldRequired
                    ? "✓"
                    : "○";

            this.requiredIconTarget.className =
                this.fieldRequired
                    ? "flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-100 text-emerald-600"
                    : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300";
        }

        if (
            this.hasRequiredLabelTarget
        ) {
            this.requiredLabelTarget.textContent =
                this.fieldRequired
                    ? "Required"
                    : "Optional";
        }

        if (
            this.hasMultipleIconTarget
        ) {
            this.multipleIconTarget.textContent =
                this.fieldMultiple
                    ? "✓"
                    : "○";

            this.multipleIconTarget.className =
                this.fieldMultiple
                    ? "flex h-8 w-8 items-center justify-center rounded-xl bg-violet-100 text-violet-600"
                    : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300";
        }

        if (
            this.hasMultipleLabelTarget
        ) {
            this.multipleLabelTarget.textContent =
                this.fieldMultiple
                    ? "Multiple"
                    : "Single";
        }

        if (
            this.hasActiveIconTarget
        ) {
            this.activeIconTarget.textContent =
                this.fieldActive
                    ? "●"
                    : "○";

            this.activeIconTarget.className =
                this.fieldActive
                    ? "flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-50 text-emerald-400"
                    : "flex h-8 w-8 items-center justify-center rounded-xl bg-slate-50 text-slate-300";
        }

        if (
            this.hasActiveLabelTarget
        ) {
            this.activeLabelTarget.textContent =
                this.fieldActive
                    ? "Enabled"
                    : "Disabled";
        }
    }

    syncFieldsToJSON() {
        const definition = {
            fields: this.fields
        };

        this.jsonTarget.value =
            stringifyDefinition(
                definition
            );

        const validation =
            validateJSON(
                this.jsonTarget.value
            );

        this.lastValidation =
            validation;

        if (
            validation.valid
        ) {
            this.renderBuilder();
            this.clearJSONError();
            this.updateStatus();
            this.dispatchDefinitionChanged();

            return;
        }

        /*
         * Keep the visual inventory synchronized even when the
         * definition currently has validation errors.
         */
        if (validation.parseValid) {
            this.fields =
                Array.isArray(validation.definition?.fields)
                    ? validation.definition.fields
                    : this.fields;

            this.renderBuilder();
        }

        this.showValidationErrors(
            validation
        );
    }

    // ============================================================
    // LIBRARY
    // ============================================================

    /*
     * Opens the definition library modal.
     *
     * The builder target is a wrapper around the actual
     * definition-library modal.
     */
    openLibrary(event) {
        console.group(
            "[entity-definition-builder] openLibrary() DEBUG"
        );

        console.log(
            "event:",
            event
        );

        console.log(
            "currentTarget:",
            event?.currentTarget
        );

        console.log(
            "controller element:",
            this.element
        );

        console.log(
            "controller element outerHTML:",
            this.element?.outerHTML?.slice(0, 5000)
        );

        console.log(
            "has libraryModal target:",
            this.hasLibraryModalTarget
        );

        console.log(
            "libraryModalTarget:",
            this.hasLibraryModalTarget
                ? this.libraryModalTarget
                : null
        );

        console.log(
            "all controller targets:",
            this.targets
        );

        console.log(
            "libraryModal elements inside controller:",
            this.element?.querySelectorAll(
                '[data-entity-definition-builder-target~="libraryModal"]'
            )
        );

        console.log(
            "ALL libraryModal targets on page:",
            document.querySelectorAll(
                '[data-entity-definition-builder-target~="libraryModal"]'
            )
        );

        console.log(
            "ALL definition-library elements:",
            document.querySelectorAll(
                '[data-controller~="definition-library"]'
            )
        );

        console.log(
            "ALL elements containing definition-library:",
            document.querySelectorAll(
                '[data-controller*="definition-library"], [data-definition-library-target]'
            )
        );

        if (!this.hasLibraryModalTarget) {
            console.error(
                "[entity-definition-builder] openLibrary(): libraryModal target DOES NOT EXIST."
            );

            console.error(
                "Expected an element like:",
                '<div data-entity-definition-builder-target="libraryModal">...</div>'
            );

            console.groupEnd();

            return;
        }

        const libraryWrapper =
            this.libraryModalTarget;

        console.log(
            "[entity-definition-builder] library wrapper FOUND:",
            libraryWrapper
        );

        console.log(
            "[entity-definition-builder] library wrapper classes:",
            libraryWrapper.className
        );

        console.log(
            "[entity-definition-builder] library wrapper aria-hidden:",
            libraryWrapper.getAttribute(
                "aria-hidden"
            )
        );

        console.log(
            "[entity-definition-builder] library wrapper data-open:",
            libraryWrapper.getAttribute(
                "data-open"
            )
        );

        let modal =
            libraryWrapper.querySelector(
                '[data-definition-library-target="modal"]'
            );

        if (!modal) {
            modal =
                document.querySelector(
                    '[data-controller~="definition-library"][data-definition-library-target="modal"]'
                );
        }

        if (!modal) {
            console.error(
                "[entity-definition-builder] openLibrary(): actual definition-library modal DOES NOT EXIST."
            );

            console.error(
                "Expected an element containing:",
                '[data-definition-library-target="modal"]'
            );

            console.groupEnd();

            return;
        }

        console.log(
            "[entity-definition-builder] ACTUAL library modal FOUND:",
            modal
        );

        console.log(
            "[entity-definition-builder] actual modal classes BEFORE:",
            modal.className
        );

        console.log(
            "[entity-definition-builder] actual modal aria-hidden BEFORE:",
            modal.getAttribute(
                "aria-hidden"
            )
        );

        console.log(
            "[entity-definition-builder] actual modal data-open BEFORE:",
            modal.getAttribute(
                "data-open"
            )
        );

        libraryWrapper.classList.remove(
            "hidden"
        );

        libraryWrapper.classList.remove(
            "invisible"
        );

        libraryWrapper.setAttribute(
            "aria-hidden",
            "false"
        );

        libraryWrapper.setAttribute(
            "data-open",
            "true"
        );

        console.log(
            "[entity-definition-builder] dispatching definition-library:open..."
        );

        modal.dispatchEvent(
            new CustomEvent(
                "definition-library:open",
                {
                    bubbles: true,
                    detail: {
                        source:
                            "entity-definition-builder"
                    }
                }
            )
        );

        window.requestAnimationFrame(
            () => {
                console.log(
                    "[entity-definition-builder] applying modal visibility fallback..."
                );

                modal.classList.remove(
                    "hidden"
                );

                modal.classList.remove(
                    "invisible"
                );

                modal.classList.add(
                    "flex"
                );

                modal.setAttribute(
                    "aria-hidden",
                    "false"
                );

                modal.setAttribute(
                    "data-open",
                    "true"
                );

                modal.classList.add(
                    "z-[100]"
                );

                console.log(
                    "[entity-definition-builder] actual modal classes AFTER:",
                    modal.className
                );

                console.log(
                    "[entity-definition-builder] actual modal aria-hidden AFTER:",
                    modal.getAttribute(
                        "aria-hidden"
                    )
                );

                console.log(
                    "[entity-definition-builder] actual modal data-open AFTER:",
                    modal.getAttribute(
                        "data-open"
                    )
                );

                console.log(
                    "[entity-definition-builder] modal visible:",
                    !modal.classList.contains(
                        "hidden"
                    )
                );

                console.log(
                    "[entity-definition-builder] modal computed display:",
                    window.getComputedStyle(
                        modal
                    ).display
                );

                console.log(
                    "[entity-definition-builder] modal computed visibility:",
                    window.getComputedStyle(
                        modal
                    ).visibility
                );

                console.log(
                    "[entity-definition-builder] modal computed opacity:",
                    window.getComputedStyle(
                        modal
                    ).opacity
                );

                console.log(
                    "[entity-definition-builder] library modal OPEN complete."
                );
            }
        );

        console.groupEnd();
    }

    /*
     * Finds the library modal.
     */
    findLibraryModal() {
        const selectors = [
            "[data-entity-definition-library-modal]",
            "[data-library-modal]",
            'dialog[data-modal="entity-definition-library"]',
            "#entity-definition-library-modal",
            "#definition-library-modal",
            "#entityDefinitionLibraryModal",
            "#entity-definition-library"
        ];

        for (
            const selector of selectors
            ) {
            const modal =
                this.element.querySelector(
                    selector
                );

            if (modal) {
                return modal;
            }
        }

        for (
            const selector of selectors
            ) {
            const modal =
                document.querySelector(
                    selector
                );

            if (modal) {
                return modal;
            }
        }

        return null;
    }

    /*
     * Optional close handler for the library modal.
     */
    closeLibrary(event) {
        if (event) {
            event.preventDefault();
            event.stopPropagation();
        }

        const modal =
            this.findLibraryModal();

        if (!modal) {
            return;
        }

        if (
            typeof HTMLDialogElement !== "undefined" &&
            modal instanceof HTMLDialogElement
        ) {
            if (modal.open) {
                modal.close();
            }

            modal.setAttribute(
                "aria-hidden",
                "true"
            );

            modal.setAttribute(
                "data-open",
                "false"
            );

            return;
        }

        modal.classList.add(
            "hidden"
        );

        modal.classList.remove(
            "flex"
        );

        modal.classList.remove(
            "invisible"
        );

        modal.setAttribute(
            "aria-hidden",
            "true"
        );

        modal.setAttribute(
            "data-open",
            "false"
        );
    }

    /*
     * Allows a library component to provide a definition through:
     *
     * event.detail.definition
     *
     * or:
     *
     * event.detail
     *
     * IMPORTANT:
     *
     * Library definitions are rendered into FIELD INVENTORY
     * immediately after their fields are successfully extracted,
     * BEFORE schema validation is evaluated.
     *
     * This means a definition can be displayed in the visual
     * builder even when it currently has invalid field names,
     * unsupported types, missing optional properties, etc.
     *
     * Validation still happens normally and the definition remains
     * marked as INVALID DEFINITION until repaired.
     */
    applyLibrary(event) {
        console.group(
            "[entity-definition-builder] applyLibrary() DEBUG"
        );

        console.log("event:", event);
        console.log("event.detail:", event?.detail);
        console.log(
            "event.detail.definition:",
            event?.detail?.definition
        );

        const detail =
            event?.detail || {};

        /*
         * Resolve definition from all supported library payload
         * formats.
         */
        let definition =
            detail.definition ||
            detail.payload?.definition ||
            detail.template?.definition ||
            detail.template?.definition_json ||
            detail.definition_json ||
            detail.payload?.definition_json ||
            detail;

        console.log(
            "resolved definition:",
            definition
        );

        if (!definition) {
            console.error(
                "[entity-definition-builder] No definition found in library event."
            );

            console.groupEnd();
            return;
        }

        if (!this.hasJsonTarget) {
            console.error(
                "[entity-definition-builder] json target is missing."
            );

            console.groupEnd();
            return;
        }

        // ------------------------------------------------------------
        // Normalize possible JSON-string definitions.
        // ------------------------------------------------------------

        let normalizedDefinition =
            definition;

        if (
            typeof normalizedDefinition ===
            "string"
        ) {
            try {
                normalizedDefinition =
                    JSON.parse(
                        normalizedDefinition
                    );
            } catch (error) {
                console.error(
                    "[entity-definition-builder] Could not parse library definition:",
                    error
                );

                this.showToast(
                    "DEFINITION LOAD FAILED",
                    "The library returned invalid definition JSON.",
                    "error"
                );

                console.groupEnd();
                return;
            }
        }

        /*
         * Some library responses wrap the actual definition in another
         * object.
         */
        if (
            !Array.isArray(
                normalizedDefinition?.fields
            )
        ) {
            if (
                Array.isArray(
                    normalizedDefinition?.definition?.fields
                )
            ) {
                normalizedDefinition =
                    normalizedDefinition.definition;
            } else if (
                Array.isArray(
                    normalizedDefinition?.definition_json?.fields
                )
            ) {
                normalizedDefinition =
                    normalizedDefinition.definition_json;
            }
        }

        console.log(
            "normalized definition:",
            normalizedDefinition
        );

        console.log(
            "normalized fields:",
            normalizedDefinition?.fields
        );

        // ------------------------------------------------------------
        // IMPORTANT FIX:
        //
        // Do NOT wait for validation.valid before populating the
        // visual builder.
        //
        // A library definition may be perfectly parseable and contain
        // useful fields while still failing schema validation.
        //
        // Example:
        //
        // fields[0].name = "First Name"
        // fields[1].type = "reference"
        //
        // These fields MUST still appear in FIELD INVENTORY so the
        // user can see/edit/repair them.
        // ------------------------------------------------------------

        if (
            Array.isArray(
                normalizedDefinition?.fields
            )
        ) {
            this.fields =
                normalizedDefinition.fields;

            console.log(
                "[entity-definition-builder] fields extracted from library:",
                this.fields
            );

            console.log(
                "[entity-definition-builder] field count:",
                this.fields.length
            );

            /*
             * Render immediately.
             *
             * This is intentionally BEFORE validateJSON().
             */
            this.renderBuilder();

            this.updateCounts();
        } else {
            console.error(
                "[entity-definition-builder] Library definition does not contain a fields array.",
                normalizedDefinition
            );

            /*
             * Do not silently replace the current visual inventory with
             * an empty array when the library payload is malformed.
             */
            this.showToast(
                "DEFINITION LOAD FAILED",
                "The selected library definition did not contain a definition fields array.",
                "error"
            );

            console.groupEnd();
            return;
        }

        // ------------------------------------------------------------
        // Write definition into JSON editor.
        // ------------------------------------------------------------

        this.jsonTarget.value =
            stringifyDefinition(
                normalizedDefinition
            );

        /*
         * A new library definition invalidates any previous repair
         * preview.
         */
        this.repairPreview = null;

        // ------------------------------------------------------------
        // Validate imported definition.
        // ------------------------------------------------------------

        const validation =
            validateJSON(
                this.jsonTarget.value
            );

        this.lastValidation =
            validation;

        console.log(
            "library definition validation:",
            validation
        );

        // ------------------------------------------------------------
        // IMPORTANT:
        //
        // If validation succeeds, synchronize from the validator.
        // This preserves any normalization performed by the validator.
        // ------------------------------------------------------------

        if (
            validation.valid
        ) {
            this.fields =
                validation.definition.fields ||
                [];

            this.renderBuilder();

            this.updateCounts();

            this.clearJSONError();

            this.updateStatus();

            this.showToast(
                "DEFINITION LOADED",
                `${this.fields.length} field${this.fields.length === 1 ? "" : "s"} imported from the library.`,
                "success"
            );

            this.dispatchDefinitionChanged();

            this.closeLibrary();

            console.groupEnd();
            return;
        }

        // ------------------------------------------------------------
        // IMPORTANT:
        //
        // The definition was parsed but failed schema validation.
        //
        // DO NOT CLEAR THE FIELDS.
        //
        // They have already been rendered above.
        //
        // We simply show the validation errors and leave the field
        // inventory populated.
        // ------------------------------------------------------------

        if (
            validation.parseValid
        ) {
            /*
             * Prefer the validator's parsed fields if available.
             * This keeps the JSON representation and visual builder
             * synchronized even while invalid.
             */
            if (
                Array.isArray(
                    validation.definition?.fields
                )
            ) {
                this.fields =
                    validation.definition.fields;
            }

            this.renderBuilder();
            this.updateCounts();

            this.showValidationErrors(
                validation
            );

            this.showToast(
                "DEFINITION LOADED WITH ISSUES",
                `${this.fields.length} field${this.fields.length === 1 ? "" : "s"} imported. Fix the definition validation problems before submitting.`,
                "warning"
            );

            /*
             * Dispatch the change even though the definition is invalid.
             *
             * Other controllers can therefore react to the newly selected
             * library template.
             */
            this.dispatchDefinitionChanged();

            this.closeLibrary();

            console.groupEnd();
            return;
        }

        // ------------------------------------------------------------
        // Truly malformed JSON.
        //
        // There is no safely parsed field array available.
        // Keep the already rendered fields rather than destroying them.
        // ------------------------------------------------------------

        console.warn(
            "[entity-definition-builder] Library definition could not be parsed:",
            validation
        );

        this.showValidationErrors(
            validation
        );

        this.showToast(
            "DEFINITION NEEDS ATTENTION",
            "The library definition was loaded but the JSON could not be parsed.",
            "warning"
        );

        console.groupEnd();
    }

    // ============================================================
    // STATUS
    // ============================================================

    updateStatus() {
        const fieldCount =
            this.fields.length;

        const requiredCount =
            this.fields.filter(
                (field) =>
                    field.required === true
            ).length;

        const activeCount =
            this.fields.filter(
                (field) =>
                    field.active !== false
            ).length;

        const progress =
            fieldCount === 0
                ? 0
                : Math.min(
                    100,
                    20 +
                    Math.min(
                        60,
                        fieldCount * 10
                    ) +
                    (requiredCount > 0
                        ? 10
                        : 0) +
                    (activeCount > 0
                        ? 10
                        : 0)
                );

        if (
            this.hasFieldCountTarget
        ) {
            this.fieldCountTarget.textContent =
                `${fieldCount} FIELD${fieldCount === 1 ? "" : "S"}`;
        }

        if (
            this.hasSidebarFieldCountTarget
        ) {
            this.sidebarFieldCountTarget.textContent =
                fieldCount;
        }

        if (
            this.hasSidebarRequiredCountTarget
        ) {
            this.sidebarRequiredCountTarget.textContent =
                requiredCount;
        }

        if (
            this.hasSidebarActiveCountTarget
        ) {
            this.sidebarActiveCountTarget.textContent =
                activeCount;
        }

        if (
            this.hasProgressLabelTarget
        ) {
            this.progressLabelTarget.textContent =
                `${progress}%`;
        }

        if (
            this.hasProgressBarTarget
        ) {
            this.progressBarTarget.style.width =
                `${progress}%`;
        }

        if (
            this.hasXpTarget
        ) {
            this.xpTarget.textContent =
                Math.round(progress);
        }

        if (
            this.hasHealthTarget
        ) {
            this.healthTarget.textContent =
                "100%";
        }

        if (
            this.hasHealthBarTarget
        ) {
            this.healthBarTarget.style.width =
                "100%";
        }

        if (
            this.hasSyncBadgeTarget
        ) {
            this.syncBadgeTarget.textContent =
                "SYNCED";
        }

        if (
            this.hasStatusTarget
        ) {
            this.statusTarget.textContent =
                "Definition builder ready";
        }

        if (
            this.hasStatusDotTarget
        ) {
            this.statusDotTarget.className =
                "h-2.5 w-2.5 rounded-full bg-emerald-500";
        }

        if (
            this.hasHeaderStatusTarget
        ) {
            this.headerStatusTarget.textContent =
                "READY";
        }

        if (
            this.hasHeaderStatusDotTarget
        ) {
            this.headerStatusDotTarget.className =
                "h-2.5 w-2.5 rounded-full bg-emerald-400";
        }

        if (
            this.hasSidebarStatusTarget
        ) {
            this.sidebarStatusTarget.textContent =
                "READY";
        }

        if (
            this.hasSubmitReadinessTarget
        ) {
            this.submitReadinessTarget.classList.remove(
                "hidden"
            );

            this.submitReadinessTarget.classList.add(
                "sm:flex"
            );
        }
    }

    setStatusError(problemCount) {
        if (
            this.hasStatusTarget
        ) {
            this.statusTarget.textContent =
                `${problemCount} definition problem${problemCount === 1 ? "" : "s"} need attention`;
        }

        if (
            this.hasStatusDotTarget
        ) {
            this.statusDotTarget.className =
                "h-2.5 w-2.5 rounded-full bg-red-500";
        }

        if (
            this.hasHeaderStatusTarget
        ) {
            this.headerStatusTarget.textContent =
                "ATTENTION";
        }

        if (
            this.hasHeaderStatusDotTarget
        ) {
            this.headerStatusDotTarget.className =
                "h-2.5 w-2.5 rounded-full bg-red-500";
        }

        if (
            this.hasSidebarStatusTarget
        ) {
            this.sidebarStatusTarget.textContent =
                "ATTENTION";
        }

        if (
            this.hasSubmitReadinessTarget
        ) {
            this.submitReadinessTarget.classList.add(
                "hidden"
            );
        }
    }

    // ============================================================
    // FORM SUBMIT
    // ============================================================

    beforeSubmit(event) {
        if (!this.hasJsonTarget) {
            return;
        }

        const validation =
            validateJSON(
                this.jsonTarget.value
            );

        this.lastValidation =
            validation;

        if (
            !validation.valid
        ) {
            event.preventDefault();

            this.showValidationErrors(
                validation
            );

            this.showToast(
                "CANNOT CREATE VERSION",
                "Fix the definition problems before submitting.",
                "error"
            );

            return;
        }

        this.jsonTarget.value =
            stringifyDefinition(
                validation.definition
            );

        this.fields =
            validation.definition.fields ||
            [];

        this.updateStatus();
    }

    // ============================================================
    // TOAST
    // ============================================================

    showToast(
        title,
        message,
        type = "success"
    ) {
        if (!this.hasToastTarget) {
            return;
        }

        this.toastTarget.classList.remove(
            "hidden"
        );

        if (
            this.hasToastTitleTarget
        ) {
            this.toastTitleTarget.textContent =
                title;
        }

        if (
            this.hasToastMessageTarget
        ) {
            this.toastMessageTarget.textContent =
                message;
        }

        if (
            this.hasToastIconTarget
        ) {
            if (type === "error") {
                this.toastIconTarget.textContent =
                    "!";

                this.toastIconTarget.className =
                    "flex h-10 w-10 items-center justify-center rounded-xl bg-red-100 text-red-600";
            } else if (
                type === "warning"
            ) {
                this.toastIconTarget.textContent =
                    "!";

                this.toastIconTarget.className =
                    "flex h-10 w-10 items-center justify-center rounded-xl bg-amber-100 text-amber-600";
            } else {
                this.toastIconTarget.textContent =
                    "✓";

                this.toastIconTarget.className =
                    "flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-100 text-emerald-600";
            }
        }

        window.clearTimeout(
            this.toastTimeout
        );

        this.toastTimeout =
            window.setTimeout(() => {
                this.toastTarget.classList.add(
                    "hidden"
                );
            }, 4500);
    }

    // ============================================================
    // HELPERS
    // ============================================================

    sameDefinition(
        first,
        second
    ) {
        try {
            return (
                JSON.stringify(first) ===
                JSON.stringify(second)
            );
        } catch {
            return false;
        }
    }

    escapeHTML(value) {
        const string =
            String(value ?? "");

        return string
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll(
                "'",
                "&#039;"
            );
    }
}