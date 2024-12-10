# Generate Import Configs

The script prioritizes the target directories if the file exists but falls back to excluding directories if it does not. Both behaviors can coexist with clear logic.
- The script has an optional **target directories config file**

---

### Updated Script: Include Target and Exclude Configurations
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

    # Define the data structure
    config_content=$(cat <<EOL
source:
  name: ""
  author: ""
  github_repo: ""
  github_url: ""
  current_version: ""
  published_version: ""
  update_available: false
group: $group_name
local:
  name: $action_name
  modifications: false
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

### How It Works:
1. **Target Config File (`target_dirs.conf`)**:
   - If this file exists, only the directories listed in it will be processed.
   - Example contents:
     ```text
     builders
     github
     utilities
     ```

2. **Exclude Config File (`exclude_dirs.conf`)**:
   - If the `target_dirs.conf` is missing, the script will exclude the directories listed in `exclude_dirs.conf`.
   - Example contents:
     ```text
     archive
     assets
     docs
     ```

3. **Processing Logic**:
   - If `target_dirs.conf` exists, only the directories listed in it will be processed, regardless of the exclusion list.
   - If `target_dirs.conf` does not exist, the script falls back to excluding directories from `exclude_dirs.conf`.

4. **Fallback Behavior**:
   - If neither file exists, all directories will be processed.

---

### Running the Script:
1. Save the script as `generate_import_configs.sh`.
2. Create one or both config files:
   - `target_dirs.conf`: To specify directories to process explicitly.
   - `exclude_dirs.conf`: To exclude specific directories.
3. Make the script executable:
   ```bash
   chmod +x generate_import_configs.sh
   ```
4. Run the script:
   - To create YAML files:
     ```bash
     ./generate_import_configs.sh
     ```
   - To create JSON files:
     ```bash
     ./generate_import_configs.sh json
     ```

---

### Example Scenario:
#### Config Files:
- **`target_dirs.conf`:**
  ```text
  builders
  github
  releases
  ```
- **`exclude_dirs.conf`:**
  ```text
  archive
  docs
  assets
  ```

#### Behavior:
- If `target_dirs.conf` exists, only `builders`, `github`, and `releases` will be processed.
- If `target_dirs.conf` is missing, `archive`, `docs`, and `assets` will be excluded.

