# Scripts for the actions monorepo

There are currently two scripts for the actions monorepo:
- `import_configs.sh`
- `monorepo_updates.sh`

The scripts update (and use) a `import-config.yml` file, which is stored for each individual action.

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

local:
  author: "john-doe"
  modifications: false

specs:
  action_file: "action.yml"
  inputs: ["input1", "input2"]
  outputs: ["output1"]
  runs:
    using: "node16"
    main: "dist/index.js"

tests:
  _comment: "reserved for future use"
```


### Notes
- **Placeholders**: If the script cannot determine certain values, placeholders (`"placeholder"`) are inserted to prompt the user for manual updates.
- **Dynamic Updates**: For imported actions, fields such as `source.latest_version` and `source.update_available` are dynamically updated based on the GitHub API.
- **Flexibility**: The file structure accommodates both locally created and imported actions, ensuring versatility in various workflows.

