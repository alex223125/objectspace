// app/javascript/controllers/entity_definition_repair.js

export default class EntityDefinitionRepair {
    constructor() {
        this.allowedNamePattern = /^[A-Za-z0-9_]+$/;
        this.reservedPrefix = "field";
    }

    /**
     * Main entry point.
     *
     * Returns:
     * {
     *   success: Boolean,
     *   definition: Object,
     *   changes: Array,
     *   warnings: Array,
     *   errors: Array
     * }
     */
    repair(input) {
        const result = {
            success: false,
            definition: null,
            changes: [],
            warnings: [],
            errors: []
        };

        let definition;

        try {
            definition = this.parse(input);
        } catch (error) {
            result.errors.push(error.message);
            return result;
        }

        if (!definition || typeof definition !== "object" || Array.isArray(definition)) {
            result.errors.push("The JSON definition must be an object.");
            return result;
        }

        const repaired = this.repairDefinition(definition, result);

        result.definition = repaired;
        result.success = result.errors.length === 0;

        return result;
    }

    /**
     * Parse JSON from either:
     * - a JSON string
     * - an already parsed object
     */
    parse(input) {
        if (typeof input === "string") {
            if (!input.trim()) {
                throw new Error("The JSON definition is empty.");
            }

            try {
                return JSON.parse(input);
            } catch (error) {
                throw new Error(`Invalid JSON syntax: ${error.message}`);
            }
        }

        if (input && typeof input === "object") {
            return this.deepClone(input);
        }

        throw new Error("The JSON definition must be valid JSON.");
    }

    /**
     * Repair the top-level definition while preserving
     * properties that we do not explicitly need to modify.
     */
    repairDefinition(definition, result) {
        const repaired = this.deepClone(definition);

        if (!Object.prototype.hasOwnProperty.call(repaired, "fields")) {
            repaired.fields = [];

            this.addChange(result, {
                field: "fields",
                originalValue: undefined,
                repairedValue: [],
                reason: "The definition did not contain a fields array, so an empty fields array was created."
            });

            return repaired;
        }

        if (!Array.isArray(repaired.fields)) {
            const originalValue = repaired.fields;

            if (originalValue && typeof originalValue === "object") {
                repaired.fields = [originalValue];

                this.addChange(result, {
                    field: "fields",
                    originalValue,
                    repairedValue: repaired.fields,
                    reason: "The fields property was an object, so it was safely converted into a one-item array."
                });
            } else {
                repaired.fields = [];

                this.addChange(result, {
                    field: "fields",
                    originalValue,
                    repairedValue: [],
                    reason: "The fields property was not an object or array, so it was replaced with an empty array."
                });

                result.warnings.push(
                    "The original fields value could not be safely converted into a field."
                );
            }

            return this.repairFields(repaired, result);
        }

        return this.repairFields(repaired, result);
    }

    /**
     * Repair each field independently.
     */
    repairFields(definition, result) {
        const usedNames = new Set();

        definition.fields = definition.fields
            .map((field, index) => {
                return this.repairField(field, index, usedNames, result);
            })
            .filter(Boolean);

        return definition;
    }

    /**
     * Repair a single field.
     */
    repairField(field, index, usedNames, result) {
        let repairedField;

        if (!field || typeof field !== "object" || Array.isArray(field)) {
            repairedField = {
                name: this.uniqueName(`field_${index + 1}`, usedNames),
                label: `Field ${index + 1}`,
                type: "string",
                description: "",
                required: false,
                multiple: false,
                active: true
            };

            this.addChange(result, {
                field: `fields[${index}]`,
                originalValue: field,
                repairedValue: repairedField,
                reason: "The field was not a valid object, so a safe default field structure was created."
            });

            result.warnings.push(
                `Field ${index + 1} was malformed and was replaced with a safe default field.`
            );

            return repairedField;
        }

        repairedField = this.deepClone(field);

        const originalName = repairedField.name;

        const normalizedName = this.normalizeFieldName(
            originalName,
            index,
            usedNames
        );

        if (normalizedName !== originalName) {
            this.addChange(result, {
                field: `fields[${index}].name`,
                originalValue: this.displayValue(originalName),
                repairedValue: normalizedName,
                reason: this.nameRepairReason(originalName, normalizedName)
            });
        }

        repairedField.name = normalizedName;

        /*
         * Preserve the label exactly as supplied whenever possible.
         *
         * We deliberately do NOT replace:
         *
         * Product Name -> product_name
         *
         * in the label.
         *
         * Only the machine-readable name changes.
         */
        if (!Object.prototype.hasOwnProperty.call(repairedField, "label")) {
            repairedField.label = this.defaultLabelFromName(normalizedName);

            this.addChange(result, {
                field: `fields[${index}].label`,
                originalValue: undefined,
                repairedValue: repairedField.label,
                reason: "The field had no label, so a readable label was generated from its repaired name."
            });
        }

        if (!Object.prototype.hasOwnProperty.call(repairedField, "description")) {
            repairedField.description = "";

            this.addChange(result, {
                field: `fields[${index}].description`,
                originalValue: undefined,
                repairedValue: "",
                reason: "The missing description property was initialized to an empty string."
            });
        }

        if (!Object.prototype.hasOwnProperty.call(repairedField, "required")) {
            repairedField.required = false;

            this.addChange(result, {
                field: `fields[${index}].required`,
                originalValue: undefined,
                repairedValue: false,
                reason: "The missing required property was initialized to false."
            });
        }

        if (!Object.prototype.hasOwnProperty.call(repairedField, "multiple")) {
            repairedField.multiple = false;

            this.addChange(result, {
                field: `fields[${index}].multiple`,
                originalValue: undefined,
                repairedValue: false,
                reason: "The missing multiple property was initialized to false."
            });
        }

        if (!Object.prototype.hasOwnProperty.call(repairedField, "active")) {
            repairedField.active = true;

            this.addChange(result, {
                field: `fields[${index}].active`,
                originalValue: undefined,
                repairedValue: true,
                reason: "The missing active property was initialized to true."
            });
        }

        return repairedField;
    }

    /**
     * Conservative field-name normalization.
     *
     * Examples:
     *
     * Product Name   -> product_name
     * Stock Quantity -> stock_quantity
     * product-name   -> product_name
     * Product.Name   -> product_name
     * 123 Product    -> field_123_product
     * Product  Name  -> product_name
     *
     * Valid names are returned unchanged except when they collide
     * with an already-used name.
     */
    normalizeFieldName(originalName, index, usedNames) {
        let value = this.coerceName(originalName);

        /*
         * Empty / missing name.
         */
        if (!value) {
            value = `${this.reservedPrefix}_${index + 1}`;
            return this.uniqueName(value, usedNames);
        }

        /*
         * Convert whitespace runs to underscores.
         */
        value = value.trim().replace(/\s+/g, "_");

        /*
         * Convert all unsupported characters to underscores.
         *
         * This handles:
         *
         * product-name
         * Product.Name
         * product/name
         * product:name
         * product$name
         */
        value = value.replace(/[^A-Za-z0-9_]/g, "_");

        /*
         * Collapse repeated underscores.
         *
         * Product  Name -> Product_Name
         * Product..Name -> Product_Name
         */
        value = value.replace(/_+/g, "_");

        /*
         * Remove underscores at the beginning/end.
         */
        value = value.replace(/^_+|_+$/g, "");

        /*
         * If everything disappeared, create a deterministic name.
         */
        if (!value) {
            value = `${this.reservedPrefix}_${index + 1}`;
        }

        /*
         * Names beginning with a number are prefixed.
         *
         * 123 Product -> field_123_product
         *
         * We do not remove information from the original name.
         */
        if (/^[0-9]/.test(value)) {
            value = `${this.reservedPrefix}_${value}`;
        }

        /*
         * The requested examples use lowercase repaired names.
         *
         * A valid existing name must NOT be changed.
         *
         * Therefore lowercasing happens only when the original
         * name required normalization.
         */
        if (this.requiresNormalization(originalName)) {
            value = value.toLowerCase();
        }

        /*
         * Final safety check.
         */
        if (!this.allowedNamePattern.test(value)) {
            value = value
                .replace(/[^A-Za-z0-9_]/g, "_")
                .replace(/_+/g, "_")
                .replace(/^_+|_+$/g, "");

            if (!value) {
                value = `${this.reservedPrefix}_${index + 1}`;
            }

            if (/^[0-9]/.test(value)) {
                value = `${this.reservedPrefix}_${value}`;
            }
        }

        return this.uniqueName(value, usedNames);
    }

    /**
     * A valid name is preserved exactly.
     *
     * Example:
     *
     * customer_id
     *
     * stays:
     *
     * customer_id
     */
    requiresNormalization(originalName) {
        if (typeof originalName !== "string") {
            return true;
        }

        if (!originalName.trim()) {
            return true;
        }

        return !this.allowedNamePattern.test(originalName);
    }

    /**
     * Convert non-string values to a safe name source.
     */
    coerceName(value) {
        if (typeof value === "string") {
            return value;
        }

        if (value === null || value === undefined) {
            return "";
        }

        if (typeof value === "number" || typeof value === "boolean") {
            return String(value);
        }

        return "";
    }

    /**
     * Deterministic duplicate handling.
     *
     * product_name
     * product_name_2
     * product_name_3
     */
    uniqueName(baseName, usedNames) {
        let candidate = baseName;

        if (!usedNames.has(candidate)) {
            usedNames.add(candidate);
            return candidate;
        }

        let counter = 2;

        while (usedNames.has(`${baseName}_${counter}`)) {
            counter += 1;
        }

        candidate = `${baseName}_${counter}`;

        usedNames.add(candidate);

        return candidate;
    }

    /**
     * Explain why a name was changed.
     */
    nameRepairReason(originalName, repairedName) {
        if (originalName === undefined || originalName === null || originalName === "") {
            return "The field had no usable name, so a deterministic safe name was generated.";
        }

        if (repairedName.match(/_\d+$/) && this.baseNameWasDuplicate(originalName)) {
            return "The field name duplicated an existing field name, so a deterministic suffix was added.";
        }

        if (typeof originalName !== "string") {
            return "The field name was not a string, so it was converted into a valid field name.";
        }

        const reasons = [];

        if (/\s/.test(originalName)) {
            reasons.push("spaces were converted to underscores");
        }

        if (/[^A-Za-z0-9_\s]/.test(originalName)) {
            reasons.push("unsupported characters were converted to underscores");
        }

        if (/_+/.test(originalName)) {
            reasons.push("repeated separators were collapsed");
        }

        if (/^[0-9]/.test(originalName.trim())) {
            reasons.push("a field_ prefix was added because names cannot start with a number");
        }

        if (originalName !== originalName.trim()) {
            reasons.push("leading and trailing whitespace was removed");
        }

        if (reasons.length === 0) {
            return "The field name was normalized to satisfy the definition naming rules.";
        }

        return `${this.capitalize(reasons.join("; "))}.`;
    }

    /**
     * This method exists so the duplicate reason can be overridden
     * later when more detailed duplicate context is available.
     */
    baseNameWasDuplicate() {
        return false;
    }

    defaultLabelFromName(name) {
        return name
            .replace(/_/g, " ")
            .replace(/\b\w/g, character => character.toUpperCase());
    }

    displayValue(value) {
        if (value === undefined) {
            return "(missing)";
        }

        if (value === null) {
            return "null";
        }

        if (typeof value === "object") {
            try {
                return JSON.stringify(value);
            } catch (_error) {
                return String(value);
            }
        }

        return String(value);
    }

    addChange(result, change) {
        result.changes.push({
            field: change.field,
            originalValue: change.originalValue,
            repairedValue: change.repairedValue,
            reason: change.reason
        });
    }

    capitalize(value) {
        if (!value) {
            return value;
        }

        return value.charAt(0).toUpperCase() + value.slice(1);
    }

    deepClone(value) {
        if (value === undefined) {
            return undefined;
        }

        return JSON.parse(JSON.stringify(value));
    }
}