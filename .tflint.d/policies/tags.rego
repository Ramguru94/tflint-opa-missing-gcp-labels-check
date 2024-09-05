package tflint

import rego.v1

import data.resources

# Define mandatory labels. Modify this list as needed.
mandatory_labels := {"Environment", "Owner"}

# Define a list of resource types
resource_types := resources.resource_types

# Fetch resources for each type and combine them
gcp_resources := [
r |
	some resource_type in resource_types
	resources := terraform.resources(resource_type, {"labels": "map(string)"}, {"expand_mode": "none"})
	some r in resources
]

# Check if labels field is missing or empty
is_unlabeled(config) if {
	not "labels" in object.keys(config)
}

is_unlabeled(config) if {
	labels := config.labels
	count(object.keys(labels)) == 0
}

# Check if mandatory labels are missing
missing_mandatory_labels(config) if {
	labels := config.labels
	missing := mandatory_labels - object.keys(labels)
	count(missing) > 0
}

# Rules for unknown labels (dynamic value)
deny_unlabeled_resource contains issue if {
	some r in gcp_resources
	labels := r.config.labels
	unknown_label := labels.unknown
	unknown_label != null
	issue := tflint.issue("Dynamic value is not allowed in labels", r.decl_range)
}

# Rules for missing or empty labels
deny_missing_labels contains issue if {
	some r in gcp_resources
	is_unlabeled(r.config)
	issue := tflint.issue("Resource must have at least one label", r.decl_range)
}

# Rules for missing mandatory labels
deny_missing_mandatory_labels contains issue if {
	some r in gcp_resources
	missing_mandatory_labels(r.config)
	issue := tflint.issue("Resource must include all mandatory labels: Environment, Owner", r.decl_range)
}
