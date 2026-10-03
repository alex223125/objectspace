export function normalizeComparisonPayload(payload = {}) {
    const changes =
        Array.isArray(payload.changes)
            ? payload.changes
            : Array.isArray(payload.differences)
                ? payload.differences
                : Array.isArray(payload.diffs)
                    ? payload.diffs
                    : Array.isArray(payload.items)
                        ? payload.items
                        : []

    return {
        ...payload,

        changes: changes.map((change) => {
            const type =
                change.type ||
                change.change_type ||
                change.kind ||
                "changed"

            return {
                ...change,

                type,

                identity_warning:
                    change.identity_warning === true ||
                    change.identityWarning === true ||
                    change.warning_type === "identity"
            }
        }),

        section_count:
            Number(
                payload.section_count ||
                payload.sectionCount ||
                1
            )
    }
}

export function comparisonChangeType(change) {
    if (!change) {
        return "changed"
    }

    return (
        change.type ||
        change.change_type ||
        change.kind ||
        "changed"
    )
}