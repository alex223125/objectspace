/**
 * Entity Definition Validator
 *
 * Phase 4:
 * - Parses JSON
 * - Validates the definition shape
 * - Reports all validation problems
 * - Does NOT repair anything
 *
 * Expected definition shape:
 *
 * {
 *   "fields": [
 *     {
 *       "name": "product_name",
 *       "label": "Product Name",
 *       "type": "string",
 *       "description": "",
 *       "required": true,
 *       "multiple": false,
 *       "active": true
 *     }
 *   ]
 * }
 */

const SUPPORTED_TYPES = new Set([
    "string",
    "text",
    "integer",
    "number",
    "boolean",
    "date",
    "datetime",
    "email",
    "url",
    "json",
    "select"
]);

const FIELD_NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;

function isPlainObject(value) {
    return (
        value !== null &&
        typeof value === "object" &&
        !Array.isArray(value)
    );
}

function pathForField(index, property = null) {
    if (property) {
        return `fields[${index}].${property}`;
    }

    return `fields[${index}]`;
}

function createProblem({
                           code,
                           path,
                           message,
                           field = null,
                           severity = "error"
                       }) {
    return {
        code,
        path,
        message,
        field,
        severity
    };
}

/**
 * Parse JSON safely.
 */
export function parseDefinitionJSON(rawValue) {
    const raw = String(rawValue ?? "");

    if (!raw.trim()) {
        return {
            valid: false,
            value: null,
            problems: [
                createProblem({
                    code: "empty_json",
                    path: "$",
                    message: "The JSON definition is empty."
                })
            ]
        };
    }

    try {
        const value = JSON.parse(raw);

        return {
            valid: true,
            value,
            problems: []
        };
    } catch (error) {
        return {
            valid: false,
            value: null,
            problems: [
                createProblem({
                    code: "invalid_json",
                    path: "$",
                    message: humanizeJSONParseError(error)
                })
            ]
        };
    }
}

/**
 * Turn browser JSON.parse errors into something useful to a human.
 */
export function humanizeJSONParseError(error) {
    const message = error?.message || "The JSON could not be parsed.";

    return `Invalid JSON syntax. ${message}`;
}

/**
 * Validate a parsed definition.
 *
 * This intentionally does not mutate the object.
 */
export function validateDefinition(definition) {
    const problems = [];

    if (!isPlainObject(definition)) {
        problems.push(
            createProblem({
                code: "root_not_object",
                path: "$",
                message: "The definition must be a JSON object."
            })
        );

        return buildValidationResult(definition, problems);
    }

    if (!Object.prototype.hasOwnProperty.call(definition, "fields")) {
        problems.push(
            createProblem({
                code: "missing_fields",
                path: "$.fields",
                message: 'The definition must contain a "fields" array.'
            })
        );

        return buildValidationResult(definition, problems);
    }

    if (!Array.isArray(definition.fields)) {
        problems.push(
            createProblem({
                code: "fields_not_array",
                path: "$.fields",
                message: '"fields" must be an array.'
            })
        );

        return buildValidationResult(definition, problems);
    }

    const names = new Map();

    definition.fields.forEach((field, index) => {
        validateField(field, index, problems, names);
    });

    return buildValidationResult(definition, problems);
}

function validateField(field, index, problems, names) {
    const path = pathForField(index);

    if (!isPlainObject(field)) {
        problems.push(
            createProblem({
                code: "field_not_object",
                path,
                message: "Each field must be a JSON object.",
                field: index
            })
        );

        return;
    }

    if (!Object.prototype.hasOwnProperty.call(field, "name")) {
        problems.push(
            createProblem({
                code: "missing_name",
                path: pathForField(index, "name"),
                message: "Field name is missing.",
                field: index
            })
        );
    } else {
        validateFieldName(field.name, index, problems, names);
    }

    if (!Object.prototype.hasOwnProperty.call(field, "label")) {
        problems.push(
            createProblem({
                code: "missing_label",
                path: pathForField(index, "label"),
                message: "Field label is missing.",
                field: index
            })
        );
    } else if (
        field.label !== null &&
        typeof field.label !== "string"
    ) {
        problems.push(
            createProblem({
                code: "invalid_label",
                path: pathForField(index, "label"),
                message: "Field label must be a string.",
                field: index
            })
        );
    }

    if (!Object.prototype.hasOwnProperty.call(field, "type")) {
        problems.push(
            createProblem({
                code: "missing_type",
                path: pathForField(index, "type"),
                message: "Field type is missing.",
                field: index
            })
        );
    } else if (!SUPPORTED_TYPES.has(String(field.type))) {
        problems.push(
            createProblem({
                code: "unsupported_type",
                path: pathForField(index, "type"),
                message: `Field type "${String(field.type)}" is not supported.`,
                field: index
            })
        );
    }

    validateBooleanProperty(
        field,
        index,
        "required",
        false,
        problems
    );

    validateBooleanProperty(
        field,
        index,
        "multiple",
        false,
        problems
    );

    validateBooleanProperty(
        field,
        index,
        "active",
        true,
        problems
    );

    if (
        Object.prototype.hasOwnProperty.call(field, "description") &&
        field.description !== null &&
        typeof field.description !== "string"
    ) {
        problems.push(
            createProblem({
                code: "invalid_description",
                path: pathForField(index, "description"),
                message: "Field description must be a string.",
                field: index
            })
        );
    }
}

function validateFieldName(name, index, problems, names) {
    if (typeof name !== "string") {
        problems.push(
            createProblem({
                code: "invalid_name_type",
                path: pathForField(index, "name"),
                message: "Field name must be a string.",
                field: index
            })
        );

        return;
    }

    if (!name.trim()) {
        problems.push(
            createProblem({
                code: "empty_name",
                path: pathForField(index, "name"),
                message: "Field name cannot be empty.",
                field: index
            })
        );

        return;
    }

    if (!FIELD_NAME_PATTERN.test(name)) {
        problems.push(
            createProblem({
                code: "invalid_name",
                path: pathForField(index, "name"),
                message:
                    'Field name must contain only letters, numbers and underscores, and must not start with a number.',
                field: index
            })
        );
    }

    const normalizedName = name.toLowerCase();

    if (names.has(normalizedName)) {
        problems.push(
            createProblem({
                code: "duplicate_name",
                path: pathForField(index, "name"),
                message: `Field name "${name}" is duplicated.`,
                field: index
            })
        );
    } else {
        names.set(normalizedName, index);
    }
}

function validateBooleanProperty(
    field,
    index,
    property,
    defaultValue,
    problems
) {
    if (!Object.prototype.hasOwnProperty.call(field, property)) {
        problems.push(
            createProblem({
                code: `missing_${property}`,
                path: pathForField(index, property),
                message: `Field "${property}" is missing.`,
                field: index,
                severity: "warning"
            })
        );

        return;
    }

    const value = field[property];

    if (typeof value !== "boolean") {
        problems.push(
            createProblem({
                code: `invalid_${property}`,
                path: pathForField(index, property),
                message: `Field "${property}" must be a boolean.`,
                field: index
            })
        );
    }
}

function buildValidationResult(definition, problems) {
    const errors = problems.filter(
        (problem) => problem.severity === "error"
    );

    const warnings = problems.filter(
        (problem) => problem.severity === "warning"
    );

    return {
        valid: errors.length === 0,
        definition,
        problems,
        errors,
        warnings,
        errorCount: errors.length,
        warningCount: warnings.length
    };
}

/**
 * Full validation pipeline:
 *
 * raw JSON
 *   -> parse
 *   -> schema validation
 */
export function validateJSON(rawValue) {
    const parsed = parseDefinitionJSON(rawValue);

    if (!parsed.valid) {
        return {
            valid: false,
            definition: null,
            problems: parsed.problems,
            errors: parsed.problems,
            warnings: [],
            errorCount: parsed.problems.length,
            warningCount: 0,
            parseValid: false,
            schemaValid: false
        };
    }

    const validation = validateDefinition(parsed.value);

    return {
        ...validation,
        parseValid: true,
        schemaValid: validation.valid
    };
}

export {
    SUPPORTED_TYPES,
    FIELD_NAME_PATTERN
};

export default {
    parseDefinitionJSON,
    validateDefinition,
    validateJSON,
    SUPPORTED_TYPES,
    FIELD_NAME_PATTERN
};