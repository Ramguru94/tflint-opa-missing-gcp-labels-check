# Dynamic Rego Policy for GCP Terraform Resources
## Overview

This repository provides tools and scripts to dynamically generate Rego policies for TFLint that enforce label requirements on Google Cloud Platform (GCP) resources defined in Terraform configurations. The scripts categorize GCP resources based on their support for labels and generate corresponding Rego policies to validate label adherence.

## Folder Structure

Here is an overview of the folder structure:

```
.
├── .tflint.d
│   └── policies
│       ├── resources.rego
│       └── tags.rego
├── .tflint.hcl
├── main.tf
├── outputs.tf
├── providers.tf
├── scripts
│   ├── generate.py
│   ├── resources_with_labels.json
│   └── resources_without_labels.json
└── variables.tf
```

- `.tflint.d/policies/`: Directory where TFLint policy files are stored.
    - `resources.rego`: Contains dynamically generated Rego policies based on the Terraform configuration.
    - `tags.rego`: Defines policies for mandatory labels and handling unlabeled resources.
- `scripts/`: Directory containing the Python script (`generate.py`) used to generate the `resources.rego` file.
- `.tflint.hcl`: Configuration file for TFLint.

## TFLint OPA Rego Policies

### 🏷️ tags.rego

The `tags.rego` file includes Rego policies that enforce label requirements on GCP resources. The policies are:

1. **Mandatory Labels** 🏷️
     - Enforces the presence of the following labels:
         - `Environment` 🌍
         - `Owner` 👤

2. **Supported Resource Types** ✅
     - Applies to resource types that support labels, as defined in the dynamically generated `resources.rego` file.

3. **Rules**
     - **Missing or Empty Labels** ❌
         - **Rule**: Resources must have at least one label.
         - **Issue**: Reports if the `labels` field is missing or empty.
     - **Missing Mandatory Labels** ❌
         - **Rule**: Resources must include all mandatory labels (`Environment`, `Owner`).
         - **Issue**: Reports if any mandatory labels are missing.
     - **Unknown Labels** ❓
         - **Rule**: Dynamic or unknown values are not allowed in labels.
         - **Issue**: Reports if a label contains dynamic or unknown values.

### Usage

1. **Policy Files** 📜
     - Place the `tags.rego` and the dynamically generated `resources.rego` file in the `.tflint.d/policies` directory.

2. **Configuration** ⚙️
     - Ensure that the `resources` data file is correctly set up to reflect the supported resource types.

3. **TFLint Configuration** ⚙️
     - The `.tflint.hcl` file should include the following configuration to enable the OPA plugin:
         ```hcl
         plugin "opa" {
             enabled = true
             version = "0.7.0"
             source  = "github.com/terraform-linters/tflint-ruleset-opa"
         }
         ```

4. **Running TFLint** ▶️
     - Validate Terraform configurations with TFLint and the Rego policies:
         ```bash
         tflint --config .tflint.hcl --recursive
         ```
     - TFLint will read the policies from the `.tflint.d/policies` directory and apply them to your Terraform configurations.

5. **Example** 🌟
     - The policy will ensure GCP resources in Terraform configurations have mandatory labels and do not have unknown or empty labels. Issues will be reported with details.

## Terraform Resource Management Script

This script automates the generation of a dynamic `resources.rego` file based on the current Terraform configuration for GCP resources.

### Requirements

- [Terraform](https://www.terraform.io/downloads) (version 0.13 or later)
- Python 3.x
- Required Python modules: `json`, `subprocess`, `os`, `shutil`, `argparse`

### Usage

1. **Basic Usage** 🚀
     - Ensure Terraform is installed and in your system's PATH.
     - Run the script to generate the Rego policy and perform other operations:
     - Navigate to scripts dir
         ```bash
         cd scripts
         ```
         and execute
         ```bash
         python3 generate.py
         ```
         This will:
         - Clean up existing Terraform files and directories.
         - Create a `provider.tf` file in the `terraform/` directory.
         - Initialize Terraform.
         - Fetch the GCP provider schema.
         - Categorize resources based on label support.
         - Generate the `resources.rego` file in the `.tflint.d/policies/` directory.

2. **Generating JSON Files** 📊
     - To generate JSON files for resources with and without labels, use the `--generate-json` flag:
     - Navigate to scripts dir
         ```bash
         cd scripts
         ```
         and execute
         ```bash
         python3 generate.py --generate-json
         ```
         This will create:
         - `resources_with_labels.json`: List of GCP resources that support labels.
         - `resources_without_labels.json`: List of GCP resources that do not support labels.

### Script Overview

- `cleanup()`: Removes the `.terraform` directory, `provider.tf` file, and any `.terraform.lock.hcl` files.
- `write_provider_tf()`: Creates a `provider.tf` file with GCP provider configuration.
- `terraform_init()`: Initializes the Terraform working directory.
- `get_gcp_provider_schema()`: Fetches the GCP provider schema in JSON format.
- `categorize_resources_by_labels(schema)`: Categorizes GCP resources based on label support.
- `write_json_file(filename, data)`: Writes data to JSON files.
- `write_rego_file(resource_types)`: Generates the `resources.rego` file with a list of resource types that support labels.
- `main()`: Coordinates script execution based on command-line arguments.

---
## Additional Information

### Contributing

If you would like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push your changes to your forked repository.
5. Submit a pull request to the main repository.
