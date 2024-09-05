tflint {
  required_version = ">= 0.52.0"
}

config {
  call_module_type = "local"
}

# https://github.com/terraform-linters/tflint-ruleset-terraform/tree/main/docs/rules
plugin "terraform" {
  enabled = true
  preset  = "all"
}

# https://github.com/terraform-linters/tflint-ruleset-google/blob/master/docs/rules
plugin "google" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

plugin "opa" {
  enabled = true
  version = "0.7.0"
  source  = "github.com/terraform-linters/tflint-ruleset-opa"
}
