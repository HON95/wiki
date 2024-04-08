---
title: Terraform
breadcrumbs:
- title: Automation
---
{% include header.md %}

## General

- Terraform is an infrastructure as code (IaC) orchestrator that integrates with many platforms using over 1000 [providers](https://registry.terraform.io/browse/providers) (e.g. AWS, Kubernetes and Grafana).
- It's a bit more declarative than Ansible, but often used together with Ansible.
- It's typically used together with Git for version control.
- Remote state:
    - It uses state files (`*.tfstate`) to keep track of the infrastructure, acting as a source of truth. These may contain secrets and must be protected and kept away from source control.
    - Remote state is an alternative to local state (described above), that avoids local credentials and suits production environments better.

## Setup

- Arch: `pacman -S terraform`
- RHEL and Debian: See the docs.
- Setup shell tab completion (BASH and ZSH): `terraform -install-autocomplete`

## Commands

- Login to Terraform Cloud: `terraform login`
    - To migrate from local to remote state, run a `terraform init` and then delete the local state files.
- Format the config: `terraform fmt`
- Validate the config: `terraform validate`
- Show resource list: `terraform state list`
- Show resource details: `terraform state show <name>`
- Show overall state (?): `terraform show`
- Install the required providers: `terraform init`
- Plan apply: `terraform plan [-out <name>.tfplan]`
- Plan destroy: `terraform plan -destroy [-out <name>.destroy.tfplan]`
- Apply (will show changes and ask for confirmation): `terraform apply [<name>.tfplan]`
    - Specify `-var "name=value"` to set input variables (override the configured defaults).
- Destroy (will show changes and ask for confirmation): `terraform destroy` (then restart the shell)

## Configuration

- A simple project setup consists of a `terraform.tf` config containing the `terraform` block with the required Terraform version and providers, as well as a `main.tf` config containing your intent. Alternatively, put everything in a single file or split it up into many files.
- Variables can be set using environment variables like `TF_VAR_yolo_id` and then accessed like `yolo2_id = var.yolo_id`

### Config Format

- Terraform uses configs in the current directory in either HCL format with extension `.tf` or JSON format with extension `.tf.json`. The notes below assume the HCL format.
- Argument syntax:
    - Example: `yolo_id = "abc123"`
    - Like variables.
    - Called "attributes" in normal HCL, but Terraform uses "arguments" to avoid confusion with other concepts in Terraform.
    - Can be given literal or generated values (expressions).
- Block syntax:
    - Example: `resource "aws_instance" "example" {}` (body inside curly braces omitted)
    - Has a _type_ (e.g. `resource`), which defines how many _labels_ are required (zero or more, specified in quotation marks) before the body.
    - Has a body delimited by curly braces, which may contain arguments and other (nested) blocks.
    - Terraform uses a limited number of top-level block types, e.g. for resources, input/output variables and data sources.
- Identifier syntax:
    - I.e. the names of arguments, blocks and other Terraform things.
    - Implements the [Unicode identifier syntax](https://unicode.org/reports/tr31/), extended with the ASCII hyphen.
    - Can contain letters, digits, underscores and hyphens, but the first character can't be a number.
- Style conventions:
    - Note: Use `terraform fmt` to enforce style conventions.
    - Indent using two spaces.
    - Align argument equals signs for consecutive lines.
    - Top-level blocks should always be separated by one blank line.
    - Avoid grouping blocks of different types, unless they form a logical family.
    - Inside a block body:
        - Place all arguments together at the top and all the subblocks together at the bottom, with one blank line in-between.
        - Separate logical groups of arguments too with one blank line. The same applies for blocks, but blocks are more commonly separated than arguments.
        - Place meta-arguments at the very top, with one blank line before the normal arguments.
        - Place meta-blocks at the very bottom, with one blank line after the normal blocks.

## Miscellanea

- Automatically created files:
    - Terraform will create a ton of files, see GitHub's [Terraform.gitignore](https://github.com/github/gitignore/blob/main/Terraform.gitignore) for inspiration.
    - If not using remote state, Terraform will create some `*.tfstate` files that may contain secrets. These MUST NOT be committed to version control. If using remote state, these files may be deleted after a `terraform init`.
    - The `.terraform.lock.hcl` file should be committed to version control.

{% include footer.md %}
