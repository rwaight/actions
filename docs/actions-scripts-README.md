# Scripts for the actions monorepo

There are currently two scripts for the actions monorepo:
- `import_configs.sh`
- `monorepo_updates.sh`

The scripts update (and use) a `import-config.yml` file, which is stored for each individual action.

**GitHub Actions Available:**
- [`utilities/import-config-maintenance`](../utilities/import-config-maintenance) - Composite action for automated import config maintenance

**Table of Contents**
- [Import Config File Specifications](#import-config-file-specifications)
- [Import Configs Script](#import-configs-script)
- [Monorepo Updates Script](#monorepo-updates-script)
- [GitHub Actions](#github-actions)

## Import Config File Specifications

The `import-config.yml` file is a structured YAML configuration file generated or updated by the `import_configs.sh` script; the file is also updated by the `monorepo_updates.sh` script. The `import-config.yml` file provides metadata and specifications for GitHub Actions, whether they are locally created or imported from external sources. Below is a breakdown of its structure and an example/template:


### File Structure

1. **Metadata Fields**:
   - **`name`**: The name of the action (derived from the directory name).
   - **`author`**: The author of the action. If not specified, a placeholder is used.
   - **`description`**: A brief description of the action. Defaults to "placeholder" if not provided.
   - **`group`**: The name of the parent directory group.

2. **Import Status**:
   - **`imported`**: A boolean indicating if the action is imported (`true`) or locally created (`false`).

3. **Source Information** (if `imported` is `true`):
   - **`source.action_name`**: The name of the imported action.
   - **`source.author`**: The author of the source action.
   - **`source.repo_name`**: The name of the GitHub repository containing the action.
   - **`source.repo_url`**: The URL of the source repository.
   - **`source.current_version`**: The version currently in use.
   - **`source.latest_version`**: The latest available version of the action.
   - **`source.update_available`**: Boolean indicating if an update is available.

4. **Local Modifications**:
   - **`local.author`**: The author of the local action (if not imported).
   - **`local.modifications`**: Boolean indicating if modifications have been made.
   - **`local.update.exclusions`**: A list of files to exclude when updating from source.

5. **Specifications**:
   - **`specs.action_file`**: The name of the action file (`action.yml` or `action.yaml`).
   - **`specs.inputs`**: A list of input keys defined in the action.
   - **`specs.outputs`**: A list of output keys defined in the action.
   - **`specs.runs.using`**: The execution environment (e.g., `node12`, `docker`).
   - **`specs.runs.main`**: The entry point file for the action (if applicable).

6. **Tests**:
   - **`tests._comment`**: A reserved section for future test-related fields.

---

### Example `import-config.yml`

```yaml
name: example-action
author: "john-doe"
description: "An example GitHub Action for demonstration purposes."
group: "example-group"
imported: true

source:
  action_name: "example-action"
  author: "external-author"
  repo_name: "example-repo"
  repo_url: "https://github.com/external-author/example-repo"
  current_version: "v1.0.0"
  latest_version: "v1.1.0"
  update_available: true
  monorepo: true
  monorepo_path: "example/"

local:
  author: "john-doe"
  modifications: false
  update:
    exclusions:
      - README-examples.md
      - example-custom-notes.md

specs:
  action_file: "action.yml"
  inputs: ["input1", "input2"]
  outputs: ["output1"]
  runs:
    using: "node20"
    main: "dist/index.js"

tests:
  _comment: "reserved for future use"
```


### Notes
- **Placeholders**: If the script cannot determine certain values, placeholders (`"placeholder"`) are inserted to prompt the user for manual updates.
- **Dynamic Updates**: For imported actions, fields such as `source.latest_version` and `source.update_available` are dynamically updated based on the GitHub API.
- **Flexibility**: The file structure accommodates both locally created and imported actions, ensuring versatility in various workflows.

---

## Import Configs Script

The `import_configs.sh` script automates the creation and maintenance of `import-config.yml` files for actions found in specified directories. It achieves the following:

1. **Read Configuration**:
   - Reads target directories from a configuration file `target_dirs.conf`.

2. **Identify Action Files**:
   - Checks each subdirectory for the presence of an `action.yml` or `action.yaml` file.

3. **Process `import-config.yml`**:
   - For each subdirectory:
     - If `import-config.yml` exists:
       - Updates fields like `author`, `description`, `specs` (including `inputs`, `outputs`, `runs`), and `source` (if applicable).
       - Checks for updates if the action is marked as "imported" by querying the GitHub API for the latest release.
     - If `import-config.yml` does not exist:
       - Prompts the user to specify if the action is "imported" or "local."
       - Generates an initial `import-config.yml` with fields such as `author`, `group`, `imported`, `specs`, and optionally, `source` details for imported actions.

4. **Extract and Format Data**:
   - Uses the `yq` tool to parse and extract data from YAML files and to update/create YAML fields.
   - Extracts keys (e.g., `inputs`, `outputs`) and converts them into a suitable format for YAML.

5. **GitHub Integration**:
   - For imported actions, fetches the latest version information from GitHub API to determine if an update is available.

6. **Handle User Input**:
   - Prompts the user to input metadata when creating `import-config.yml` for new actions, especially for imported actions.

7. **Iterate Over All Actions**:
   - Processes every subdirectory in the target directories, ensuring that all actions are updated or have an `import-config.yml` generated.

8. **Placeholder Values**:
   - Inserts placeholders for fields like `author` or `description` if they are missing in the action file.

9. **Reserved Tests Section**:
   - Adds a `tests` block in the `import-config.yml` file for future use.

10. **Output**:
    - Displays progress and completion messages for each action processed.

### Notes

This script is designed to be extensible and works efficiently for managing configurations of multiple GitHub Actions. It uses `yq` for YAML manipulation, `jq` for JSON parsing, and assumes user access to GitHub API for imported action metadata.

---

## Monorepo Updates Script

This script automates the process of checking for updates in repositories and applying those updates to the actions monorepo based on configurations specified in `import-config.yml` files within target directories. It achieves the following:

1. **Configuration Loading**:
   - Reads target directories from `target_dirs.conf`.
   - Optionally allows specifying a specific group and action to process instead of using all target directories.

2. **Update Check Logic**:
   - For each `import-config.yml` file found in the target directories:
       - Checks if the action is "imported."
       - Verifies if an update is available by comparing the current version with the latest version.
       - Fetches the latest version information from the repository using GitHub APIs (via `curl` and `jq`).

3. **Repository Update Process**:
   - Clones the repository at the specified latest version.
   - Processes the repository:
       - Renames `.github/` directory to `__dot_github/` and disables `.yml` files within.
       - Adds a repository name prefix to `.md` and `.yml` files.
   - Creates a new branch in the actions monorepo for the update.
   - Generates a new `README.md` based on a template (`imported_readme_template.md`), using `sed` to populate placeholders with details (e.g., group name, action name, new version).
       - Eventually this will be managed by a workflow within the actions repo.

4. **Git Workflow**:
   - Prepares changes for a commit (does not auto-commit or push).
   - Provides instructions for the user to commit and push changes manually.

5. **Temporary Directory Management**:
   - Uses a temporary directory for processing repository updates.
   - Prompts the user for cleanup after processing.

6. **Configuration File Update**:
   - Updates the `current_version` and `update_available` fields in `import-config.yml` after successful processing.

### Notes

The script also has some _interactive features_:
- Prompts the user for specifying specific actions to update.
- Offers manual intervention for committing, pushing changes, and cleaning up temporary directories.

---

## GitHub Actions

### Import Config Maintenance Action

A composite GitHub Action version of the `import_configs.sh` script is available at [`utilities/import-config-maintenance`](../utilities/import-config-maintenance).

**Key Differences from the Script:**
- Runs non-interactively in GitHub Actions workflows
- Reads `target_dirs.conf` automatically (no need to pass directories)
- Cannot create new `import-config.yml` files (use the script for that)
- Provides structured outputs for workflow automation
- Supports dry-run mode for testing

**Usage Example:**
```yaml
- name: Checkout repository
  uses: actions/checkout@v4

- name: Maintain import configs
  id: maintain
  uses: rwaight/actions/utilities/import-config-maintenance@main

- name: Commit changes
  if: steps.maintain.outputs.actions-updated > 0
  uses: rwaight/actions/git/add-and-commit@main
  with:
    message: 'chore: update import-config.yml files'
```

See the [action's README](../utilities/import-config-maintenance/README.md) for full documentation.

