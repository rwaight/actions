#!/bin/bash

# Read target directories from the config file
target_dirs=($(cat target_dirs.conf))

# Function to create import-config.yml for each action
create_import_config() {
    local group_dir=$1
    local action_dir=$2
    #echo "Processing ${group_dir}/${action_dir}"
    #echo "  group_dir is ${group_dir}"
    #echo "  action_dir is ${action_dir}"

    # Prompt the user to find out if the action is imported or locally-created
    #read -p "Is the action in ${group_dir}/${action_dir} imported or locally-created (imported/local)?" action_type
    #read -p "Is the action in ${action_dir} imported or locally-created (imported/local)?  " action_type
    read -p "Is ${action_dir} imported or locally-created (imported/local)?  " action_type

    # Set initial values for import-config.yml
    group=$(basename "$group_dir")
    name=$(basename "$action_dir")
    imported=false
    local_author="rwaight"
    modifications=false

    if [[ $action_type == "imported" ]]; then
        imported=true
        read -p "Enter source action name [default: $name]: " source_action_name
        source_action_name=${source_action_name:-$name}
        read -p "Enter source action author: " source_action_author
        read -p "Enter source GitHub repo name [default: $name]: " source_repo_name
        source_repo_name=${source_repo_name:-$name}
        source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
        read -p "Enter current version used: " current_version
        latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
        update_available=false
        if [[ $current_version != $latest_version ]]; then
            update_available=true
        fi
    else
        read -p "Has there been any modifications? (true/false): " modifications
    fi

    # Read inputs, outputs, and runs from action.yml
    #action_file="${group_dir}/${action_dir}/action.yml"
    action_file="${action_dir}/action.yml"
    inputs=$(yq .inputs $action_file)
    outputs=$(yq .outputs $action_file)
    runs=$(yq .runs $action_file | jq '{using, main}')

    # Create import-config.yml content
    import_config=$(cat <<EOF
imported: $imported
name: $name
description: ""
group: $group
inputs: $inputs
outputs: $outputs
runs: $runs
tests:
  _comment: "reserved for future use"
EOF
    )

    if [[ $imported == "true" ]]; then
        import_config+=$(
cat <<EOF
source:
  action_name: $source_action_name
  author: $source_action_author
  repo_name: $source_repo_name
  repo_url: $source_repo_url
  current_version: $current_version
  latest_version: $latest_version
  update_available: $update_available
EOF
        )
    else
        import_config+=$(
cat <<EOF
local:
  author: $local_author
  modifications: $modifications
EOF
        )
    fi

    # Write import-config.yml file
    echo "$import_config" > "${group_dir}/${action_dir}/import-config.yml"
    echo "Created import-config.yml for ${group_dir}/${action_dir}"
}

# Iterate through each group directory
for group_dir in "${target_dirs[@]}"; do
    for action_dir in "$group_dir"/*; do
        if [[ -d "$action_dir" ]]; then
            create_import_config "$group_dir" "$action_dir"
        fi
    done
done
