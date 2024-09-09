import json
import subprocess
import os
import shutil
import argparse

def cleanup():
    """
    Cleans up the .terraform directory, provider.tf file, and any .terraform.lock.hcl files.
    """
    # Remove .terraform directory if it exists
    if os.path.exists(".terraform"):
        shutil.rmtree(".terraform")
        print(".terraform directory removed.")

    # Remove provider.tf file if it exists
    if os.path.exists("provider.tf"):
        os.remove("provider.tf")
        print("provider.tf file removed.")
    
    # Remove .terraform.lock.hcl files if they exist
    for filename in os.listdir("."):
        if filename.endswith(".terraform.lock.hcl"):
            os.remove(filename)
            print(f"{filename} file removed.")

def write_provider_tf():
    """
    Writes the provider.tf configuration file.
    """
    provider_config = """
terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}
    """.strip()  # Strip leading and trailing whitespace

    try:
        with open('provider.tf', 'w') as file:
            file.write(provider_config)
        print("provider.tf file created.")
    except IOError as e:
        print("Error writing provider.tf file:", e)
        return False
    return True

def terraform_init():
    """
    Runs 'terraform init' to initialize the Terraform working directory.
    """
    try:
        subprocess.run(
            ["terraform", "init"],
            check=True
        )
        print("Terraform initialization complete.")
    except subprocess.CalledProcessError as e:
        print("Error during 'terraform init':", e)
        return False
    return True

def get_gcp_provider_schema():
    """
    Fetches the GCP provider schema using the 'terraform providers schema' command.
    """
    try:
        result = subprocess.run(
            ["terraform", "providers", "schema", "-json"],
            capture_output=True,
            text=True,
            check=True
        )
        schema = json.loads(result.stdout)
        return schema
    except subprocess.CalledProcessError as e:
        print("Error fetching provider schema:", e)
        return None

def categorize_resources_by_labels(schema):
    """
    Categorizes GCP resources into those that support labels and those that do not.
    """
    resources_with_labels = []
    resources_without_labels = []
    gcp_provider = schema.get("provider_schemas", {}).get("registry.terraform.io/hashicorp/google", {})

    if not gcp_provider:
        print("GCP provider schema not found in the fetched schema.")
        return resources_with_labels, resources_without_labels

    resources = gcp_provider.get("resource_schemas", {})

    for resource_name, resource_details in resources.items():
        block = resource_details.get("block", {})
        attributes = block.get("attributes", {})
        if "labels" in attributes:
            resources_with_labels.append(resource_name)
        else:
            resources_without_labels.append(resource_name)

    return resources_with_labels, resources_without_labels

def write_json_file(filename, data):
    """
    Writes the data to a JSON file.
    """
    try:
        with open(filename, 'w') as file:
            json.dump(data, file, indent=2)
        print(f"{filename} file created.")
    except IOError as e:
        print(f"Error writing {filename} file:", e)

def write_rego_file(resource_types):
    """
    Writes the resources.rego file with the list of resource types that support labels.
    """
    rego_dir = "../.tflint.d/policies"
    os.makedirs(rego_dir, exist_ok=True)  # Ensure the directory exists

    rego_content = f"""# This file is generated from scripts/generate.py. Do not edit it directly.
package resources

import rego.v1

# Define a list of resource types that support labels
resource_types := {json.dumps(resource_types, indent=2, separators=(',', ': '))}
    """.strip()  # Strip leading and trailing whitespace

    rego_path = os.path.join(rego_dir, 'resources.rego')
    
    try:
        with open(rego_path, 'w') as file:
            file.write(rego_content)
        print(f"{rego_path} file created.")
    except IOError as e:
        print("Error writing resources.rego file:", e)

def main():
    parser = argparse.ArgumentParser(description="Generate Terraform and OPA Rego files.")
    parser.add_argument("--generate-json", action="store_true", help="Generate JSON files for resources with and without labels.")
    args = parser.parse_args()

    cleanup()
    
    if not write_provider_tf():
        return

    if not terraform_init():
        return

    schema = get_gcp_provider_schema()
    if not schema:
        return

    resources_with_labels, resources_without_labels = categorize_resources_by_labels(schema)

    if args.generate_json:
        write_json_file('resources_with_labels.json', resources_with_labels)
        write_json_file('resources_without_labels.json', resources_without_labels)
    else:
        write_rego_file(resources_with_labels)

    cleanup()  # Clean up after processing

if __name__ == "__main__":
    main()
