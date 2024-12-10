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

# Loop through all top-level directories (groups)
for group_dir in */; do
  group_name=$(basename "$group_dir")
  
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
