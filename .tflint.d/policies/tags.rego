package tflint

import rego.v1

# Fetch resources for each type and combine them
resources := terraform.resources("google_compute_disk", {"labels": "map(string)"}, {"expand_mode": "none"})

mandatory_labels := {"Environment", "Owner"}

is_untagged(config) if {
	is_null(config.labels.value)
}

is_untagged(config) if {
	not is_null(config.labels.value)
	not "Environment" in object.keys(config.labels.value)
}

missing_mandatory_labels(config) if {
	not is_null(config.labels.value)
	labels := config.labels.value
	missing := mandatory_labels - object.keys(labels)
	count(missing) > 0
}

is_untagged(config) if {
	not "labels" in object.keys(config)
}

# Rules for unlabeled resources
deny_untagged_instance contains issue if {
	is_untagged(resources[i].config)

	issue := tflint.issue(`instance missing labels or set to null`, resources[i].decl_range)
}

deny_missing_labels contains issue if {
	missing_mandatory_labels(resources[i].config)
	issue := tflint.issue(`instance missing required lables`, resources[i].decl_range)
}
