# Generate Import Configs

The script performs the following:
- Directory Traversal
    - Loops through all top-level directories (groups) and their subdirectories (actions).
    - Prioritizes the target directories if the file exists but falls back to excluding directories if it does not.
        - Both behaviors can coexist with clear logic.
        - The script has an optional **target directories config file**
- File Creation
    - For each action, it creates an `import-config.yaml` file
        - Default placeholders for source details and populates `group` and `local.name` fields using the directory names.
    - Prompts you to provide input for each field when generating the `import-config` file
        - You can choose to either populate the fields interactively or keep them empty for later editing.
- Output
    - An `import-config` file is created in each action directory
    - Each file will be tailored to the specific action but with placeholder values for most fields.

---

### Updated Script: Prompt for Field Input
```bash
#!/bin/bash

# Default file format
file_format="yaml"

# Check for user-specified file format
if [[ "$1" == "json" ]]; then
  file_format="json"
elif [[ "$1" != "" && "$1" != "yaml" ]]; then
  echo "Invalid format specified. Please use 'yaml' (default) or 'json'."
  exit 1
fi

# Config files
exclude_config_file="exclude_dirs.conf"
target_config_file="target_dirs.conf"

# Initialize arrays
exclude_dirs=()
target_dirs=()

# Check for exclude directories config file
if [[ -f "$exclude_config_file" ]]; then
  mapfile -t exclude_dirs < "$exclude_config_file"
else
  echo "Exclude config file ($exclude_config_file) not found. No directories will be excluded."
fi

# Check for target directories config file
if [[ -f "$target_config_file" ]]; then
  mapfile -t target_dirs < "$target_config_file"
  echo "Target config file ($target_config_file) found. Only target directories will be processed."
fi

# Function to prompt for input with a default value
prompt_for_input() {
  local prompt_message="$1"
  local default_value="$2"
  read -p "$prompt_message [$default_value]: " input_value
  echo "${input_value:-$default_value}"
}

# Loop through all top-level directories
for group_dir in */; do
  group_name=$(basename "$group_dir")

  # If target_dirs exists, only process directories in the target list
  if [[ -n "${target_dirs[*]}" && ! " ${target_dirs[*]} " =~ " $group_name " ]]; then
    echo "Skipping directory not in target list: $group_name"
    continue
  fi

  # If exclude_dirs exists and no target_dirs, skip excluded directories
  if [[ -z "${target_dirs[*]}" && " ${exclude_dirs[*]} " =~ " $group_name " ]]; then
    echo "Skipping excluded directory: $group_name"
    continue
  fi

  # Loop through all subdirectories (actions) within each group
  for action_dir in "$group_dir"*/; do
    action_name=$(basename "$action_dir")
    config_file="$action_dir/import-config.$file_format"

    echo "Creating import-config for action: $group_name/$action_name"

    # Prompt for input values for each field
    source_name=$(prompt_for_input "Source action name" "")
    source_author=$(prompt_for_input "Source author" "")
    github_repo=$(prompt_for_input "Source GitHub repo" "")
    github_url=$(prompt_for_input "Source GitHub URL" "")
    current_version=$(prompt_for_input "Current source version used" "")
    published_version=$(prompt_for_input "Current source published version" "")
    update_available=$(prompt_for_input "Update available (true/false)" "false")
    local_modifications=$(prompt_for_input "Local modifications (true/false)" "false")

    # Define the data structure
    config_content=$(cat <<EOL
source:
  name: "$source_name"
  author: "$source_author"
  github_repo: "$github_repo"
  github_url: "$github_url"
  current_version: "$current_version"
  published_version: "$published_version"
  update_available: $update_available
group: "$group_name"
local:
  name: "$action_name"
  modifications: $local_modifications
EOL
    )

    # Write the configuration in YAML or JSON format
    if [[ "$file_format" == "yaml" ]]; then
      echo "$config_content" > "$config_file"
    else
      # Convert the YAML content to JSON using `yq`
      echo "$config_content" | yq eval -o=json - > "$config_file"
    fi

    echo "Created $config_file"
  done
done

echo "Finished generating import-config.$file_format files for all actions."
```

---

### Features:
1. **Interactive Prompts**:
   - For each action, the script prompts you to input values for all fields:
     - `source.name`
     - `source.author`
     - `source.github_repo`
     - `source.github_url`
     - `source.current_version`
     - `source.published_version`
     - `source.update_available` (default: `false`)
     - `local.modifications` (default: `false`)

2. **Defaults for Boolean Fields**:
   - Boolean fields (`update_available`, `local.modifications`) default to `false` but can be overridden interactively.

3. **Optional JSON Output**:
   - The script supports generating either YAML (default) or JSON files using the `yq` tool for conversion.

4. **Configurable Directory Handling**:
   - Target directories (`target_dirs.conf`) and excluded directories (`exclude_dirs.conf`) are fully supported.

---

### Running the Script:
1. Save the script as `generate_import_configs.sh`.
2. Create the `target_dirs.conf` and/or `exclude_dirs.conf` files, as needed.
3. Make the script executable:
   ```bash
   chmod +x generate_import_configs.sh
   ```
4. Run the script:
   - For YAML files:
     ```bash
     ./generate_import_configs.sh
     ```
   - For JSON files:
     ```bash
     ./generate_import_configs.sh json
     ```

---

### Example Interaction:
#### Input Prompts for an action:
```text
Creating import-config for action: builders/set-version
Source action name []: Set Version Action
Source author []: John Doe
Source GitHub repo []: actions/set-version
Source GitHub URL []: https://github.com/actions/set-version
Current source version used []: v1.0.0
Current source published version []: v1.2.0
Update available (true/false) [false]: true
Local modifications (true/false) [false]: false
```

#### Generated `import-config.yaml`:
```yaml
source:
  name: "Set Version Action"
  author: "John Doe"
  github_repo: "actions/set-version"
  github_url: "https://github.com/actions/set-version"
  current_version: "v1.0.0"
  published_version: "v1.2.0"
  update_available: true
group: "builders"
local:
  name: "set-version"
  modifications: false
```

