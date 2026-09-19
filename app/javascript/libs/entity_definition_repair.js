/**
 * Entity Definition Repair Engine
 *
 * Conservative repair engine.
 *
 * Important:
 * - Does not modify the original object.
 * - Produces a repaired copy.
 * - Produces a deterministic change log.
 * - Does not automatically apply the repair.
 */

import {
    SUPPORTED_TYPES,
    FIELD_NAME_PATTERN
} from "./entity_definition_validator";

const DEFAULT_TYPE = "string";

const BOOLEAN_DEFAULTS = {
    required: false,
    multiple: false,
    active: true
};

function isPlainObject(value) {
    return (
        value !== null &&
        typeof value === "object" &&
        !Array.isArray(value)
    );
}

function deepClone(value) {
    if (typeof structuredClone === "function") {
        return structuredClone(value);
    }

    return JSON.parse(JSON.stringify(value));
}

/**
 * Main repair function.
 */
export function repairDefinition(definition) {
    const original = deepClone(definition);

    const changes = [];
    const warnings = [];

    if (!isPlainObject(definition)) {
        return {
            repairedDefinition: {
                fields: []
            },
            changes: [
                {
                    field: "definition",
                    property: null,
                    originalValue: definition,
                    repairedValue: {
                        fields: []
                    },
                    reason:
                        "The root definition was not an object, so a safe empty definition was created.",
                    destructive: true
                }
            ],
            warnings: [
                "The original definition was not an object. The repair replaced it with an empty definition."
            ],
            changed: true,
            destructive: true,
            original
        };
    }

    const repaired = deepClone(definition);

    if (!Array.isArray(repaired.fields)) {
        const originalFields = repaired.fields;

        repaired.fields = [];

        changes.push({
            field: "definition",
            property: "fields",
            originalValue: originalFields,
            repairedValue: [],
            reason:
                'The "fields" property was missing or was not an array. A safe empty fields array was created.',
            destructive: originalFields !== undefined
        });

        if (
            originalFields !== undefined &&
            originalFields !== null
        ) {
            warnings.push(
                'The original "fields" value could not be safely interpreted as a field list.'
            );
        }
    }

    const usedNames = new Set();

    repaired.fields = repaired.fields.map((field, index) => {
        return repairField(
            field,
            index,
            usedNames,
            changes,
            warnings
        );
    });

    return {
        repairedDefinition: repaired,
        changes,
        warnings,
        changed: changes.length > 0,
        destructive:
            changes.some((change) => change.destructive) ||
            warnings.length > 0,
        original
    };
}

function repairField(
    originalField,
    index,
    usedNames,
    changes,
    warnings
) {
    const fieldLabel = `Field ${index + 1}`;

    if (!isPlainObject(originalField)) {
        const repairedField = {
            name: createUniqueName(
                `field_${index + 1}`,
                usedNames
            ),
            label: "",
            type: DEFAULT_TYPE,
            description: "",
            required: false,
            multiple: false,
            active: true
        };

        changes.push({
            field: fieldLabel,
            property: null,
            originalValue: originalField,
            repairedValue: repairedField,
            reason:
                "The field was not an object. A safe default field structure was created.",
            destructive: true
        });

        warnings.push(
            `${fieldLabel} was not an object and was replaced with a safe default field.`
        );

        return repairedField;
    }

    const field = deepClone(originalField);

    repairName(
        field,
        index,
        usedNames,
        changes,
        warnings
    );

    repairLabel(
        field,
        index,
        changes
    );

    repairType(
        field,
        index,
        changes,
        warnings
    );

    repairDescription(
        field,
        index,
        changes
    );

    repairBoolean(
        field,
        index,
        "required",
        changes
    );

    repairBoolean(
        field,
        index,
        "multiple",
        changes
    );

    repairBoolean(
        field,
        index,
        "active",
        changes
    );

    return field;
}

function repairName(
    field,
    index,
    usedNames,
    changes,
    warnings
) {
    const originalName = field.name;

    let candidate;

    if (
        typeof originalName === "string" &&
        originalName.trim()
    ) {
        candidate = normalizeFieldName(originalName);
    } else {
        const fallbackLabel =
            typeof field.label === "string"
                ? field.label
                : "";

        candidate = normalizeFieldName(fallbackLabel);

        if (!candidate) {
            candidate = `field_${index + 1}`;
        }

        warnings.push(
            `Field ${index + 1} had an empty or missing name. A name was generated automatically.`
        );
    }

    if (!candidate) {
        candidate = `field_${index + 1}`;
    }

    const uniqueName = createUniqueName(
        candidate,
        usedNames
    );

    usedNames.add(uniqueName.toLowerCase());

    if (originalName !== uniqueName) {
        let reason;

        if (
            typeof originalName === "string" &&
            originalName.trim() &&
            !FIELD_NAME_PATTERN.test(originalName)
        ) {
            reason =
                "Field names must contain only letters, numbers and underscores. Invalid characters were normalized.";
        } else if (
            typeof originalName === "string" &&
            originalName.trim() &&
            originalName.toLowerCase() !== uniqueName.toLowerCase()
        ) {
            reason =
                "The field name conflicted with another field, so a deterministic unique suffix was added.";
        } else {
            reason =
                "The field did not have a usable name, so a safe field name was generated.";
        }

        changes.push({
            field: fieldDisplayName(field, index),
            property: "name",
            originalValue:
                originalName === undefined
                    ? "(missing)"
                    : originalName,
            repairedValue: uniqueName,
            reason,
            destructive: false
        });

        field.name = uniqueName;
    } else {
        field.name = uniqueName;
    }
}

function repairLabel(field, index, changes) {
    const originalLabel = field.label;

    if (
        originalLabel === undefined ||
        originalLabel === null
    ) {
        const generatedLabel = humanizeFieldName(field.name);

        field.label = generatedLabel;

        changes.push({
            field: fieldDisplayName(field, index),
            property: "label",
            originalValue:
                originalLabel === undefined
                    ? "(missing)"
                    : originalLabel,
            repairedValue: generatedLabel,
            reason:
                "The label was missing, so it was generated from the repaired field name.",
            destructive: false
        });

        return;
    }

    if (typeof originalLabel !== "string") {
        const repairedLabel = String(originalLabel);

        field.label = repairedLabel;

        changes.push({
            field: fieldDisplayName(field, index),
            property: "label",
            originalValue: originalLabel,
            repairedValue: repairedLabel,
            reason:
                "The label must be a string, so the existing value was converted to text.",
            destructive: false
        });
    }
}

function repairType(
    field,
    index,
    changes,
    warnings
) {
    const originalType = field.type;

    if (
        typeof originalType === "string" &&
        SUPPORTED_TYPES.has(originalType)
    ) {
        return;
    }

    const normalizedType =
        typeof originalType === "string"
            ? originalType.trim().toLowerCase()
            : "";

    if (SUPPORTED_TYPES.has(normalizedType)) {
        field.type = normalizedType;

        changes.push({
            field: fieldDisplayName(field, index),
            property: "type",
            originalValue: originalType,
            repairedValue: normalizedType,
            reason:
                "The supported field type was normalized to the canonical lowercase value.",
            destructive: false
        });

        return;
    }

    field.type = DEFAULT_TYPE;

    changes.push({
        field: fieldDisplayName(field, index),
        property: "type",
        originalValue:
            originalType === undefined
                ? "(missing)"
                : originalType,
        repairedValue: DEFAULT_TYPE,
        reason:
            "The field type was missing or unsupported. It was changed to the safe default type \"string\".",
        destructive: true
    });

    warnings.push(
        `${fieldDisplayName(field, index)} had an unsupported type and was changed to "string".`
    );
}

function repairDescription(field, index, changes) {
    const originalDescription = field.description;

    if (
        originalDescription === undefined ||
        originalDescription === null
    ) {
        field.description = "";

        changes.push({
            field: fieldDisplayName(field, index),
            property: "description",
            originalValue:
                originalDescription === undefined
                    ? "(missing)"
                    : originalDescription,
            repairedValue: "",
            reason:
                "The description property was missing, so an empty description was added.",
            destructive: false
        });

        return;
    }

    if (typeof originalDescription !== "string") {
        const repairedDescription =
            String(originalDescription);

        field.description = repairedDescription;

        changes.push({
            field: fieldDisplayName(field, index),
            property: "description",
            originalValue: originalDescription,
            repairedValue: repairedDescription,
            reason:
                "The description must be text, so the existing value was converted to a string.",
            destructive: false
        });
    }
}

function repairBoolean(
    field,
    index,
    property,
    changes
) {
    const originalValue = field[property];

    if (typeof originalValue === "boolean") {
        return;
    }

    const normalized = normalizeBoolean(
        originalValue
    );

    if (normalized !== null) {
        field[property] = normalized;

        changes.push({
            field: fieldDisplayName(field, index),
            property,
            originalValue:
                originalValue === undefined
                    ? "(missing)"
                    : originalValue,
            repairedValue: normalized,
            reason:
                `The "${property}" property was normalized to a boolean.`,
            destructive: false
        });

        return;
    }

    const defaultValue =
        BOOLEAN_DEFAULTS[property];

    field[property] = defaultValue;

    changes.push({
        field: fieldDisplayName(field, index),
        property,
        originalValue:
            originalValue === undefined
                ? "(missing)"
                : originalValue,
        repairedValue: defaultValue,
        reason:
            `The "${property}" property was missing or invalid and was replaced with its safe default.`,
        destructive: false
    });
}

function normalizeBoolean(value) {
    if (typeof value === "boolean") {
        return value;
    }

    if (typeof value === "number") {
        if (value === 1) return true;
        if (value === 0) return false;
    }

    if (typeof value === "string") {
        const normalized = value
            .trim()
            .toLowerCase();

        if (
            ["true", "1", "yes", "y", "on"].includes(
                normalized
            )
        ) {
            return true;
        }

        if (
            ["false", "0", "no", "n", "off"].includes(
                normalized
            )
        ) {
            return false;
        }
    }

    return null;
}

/**
 * Conservative field-name normalization.
 */
export function normalizeFieldName(value) {
    if (typeof value !== "string") {
        return "";
    }

    let normalized = value.trim();

    if (!normalized) {
        return "";
    }

    normalized = normalized
        .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
        .toLowerCase();

    normalized = normalized.replace(
        /[^a-z0-9_]+/g,
        "_"
    );

    normalized = normalized.replace(
        /_+/g,
        "_"
    );

    normalized = normalized.replace(
        /^_+|_+$/g,
        ""
    );

    if (!normalized) {
        return "";
    }

    if (/^[0-9]/.test(normalized)) {
        normalized = `field_${normalized}`;
    }

    return normalized;
}

function createUniqueName(
    baseName,
    usedNames
) {
    let candidate = baseName || "field";

    if (!usedNames.has(candidate.toLowerCase())) {
        return candidate;
    }

    let counter = 2;

    while (
        usedNames.has(
            `${candidate}_${counter}`.toLowerCase()
        )
        ) {
        counter += 1;
    }

    return `${candidate}_${counter}`;
}

function humanizeFieldName(name) {
    if (!name) {
        return "Field";
    }

    return name
        .replace(/_/g, " ")
        .replace(/\b\w/g, (letter) =>
            letter.toUpperCase()
        );
}

function fieldDisplayName(field, index) {
    if (
        typeof field?.label === "string" &&
        field.label.trim()
    ) {
        return field.label;
    }

    if (
        typeof field?.name === "string" &&
        field.name.trim()
    ) {
        return field.name;
    }

    return `Field ${index + 1}`;
}

/**
 * Format repaired JSON for the editor.
 */
export function stringifyDefinition(definition) {
    return JSON.stringify(
        definition,
        null,
        2
    );
}

export default {
    repairDefinition,
    normalizeFieldName,
    stringifyDefinition
};