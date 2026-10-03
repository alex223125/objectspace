export const comparisonIntelligenceSchema = {
    changes: [
        {
            type: "changed",
            path: "identity.name",
            label: "Name",
            oldValue: "Example",
            newValue: "Example 2"
        },
        {
            type: "added",
            path: "methods.new_method",
            label: "New Method"
        },
        {
            type: "removed",
            path: "history.old_event",
            label: "Historical Event"
        },
        {
            type: "moved",
            path: "architecture.section",
            label: "Architecture Section"
        },
        {
            type: "identity",
            path: "identity.entity_type",
            label: "Entity Type"
        }
    ]
}

export default comparisonIntelligenceSchema