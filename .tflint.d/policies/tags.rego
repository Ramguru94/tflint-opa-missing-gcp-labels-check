package tflint

import rego.v1

import data.resources

resource_types := resources.resource_types

gcp_resources := [
    r |
    some resource_type in resource_types
    resources := terraform.resources(resource_type, {"labels": "map(string)"}, {"expand_mode": "none"})
    some r in resources
]

mandatory_labels := {"Environment", "Platform"}

# Helper Functions
is_untagged(config) if {
    not "labels" in object.keys(config)  # Labels field is missing
}

is_untagged(config) if {
    "labels" in object.keys(config)
    is_null(config.labels.value)  # Labels are null
}

is_untagged(config) if {
    "labels" in object.keys(config)
    not is_null(config.labels.value)
    count(object.keys(config.labels.value)) == 0  # Labels exist but are empty
}

missing_mandatory_labels(config) := missing if {
    not is_null(config.labels.value)
    labels := config.labels.value
    missing := {label | label := mandatory_labels[_]; not label in object.keys(labels)}
    count(missing) > 0
}

concat_missing_labels(missing) = output if {
    # Convert the set of missing labels into an array of strings
    missing_array := [label | label := missing[_]]
    output := concat(", ", missing_array)  # Join the array into a comma-separated string
}

# Group: Label Checks
# Rule for resources missing labels or with null labels
deny_missing_labels_field contains issue if {
    some r in gcp_resources
    is_untagged(r.config)

    issue := tflint.issue(`resource missing labels or set to null`, r.decl_range)
}

# Rule for resources missing mandatory labels
deny_missing_mandatory_labels contains issue if {
    some r in gcp_resources
    missing := missing_mandatory_labels(r.config)

    # Use the helper function to join the missing labels into a comma-separated string
    missing_tags := concat_missing_labels(missing)

    # Create an issue with the list of missing mandatory labels
    issue := tflint.issue(sprintf("resource missing required labels: %s", [missing_tags]), r.decl_range)
}
