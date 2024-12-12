#!/bin/bash

# Read target directories from the config file
target_dirs=($(cat target_dirs.conf))

# Function to read the action.yml or action.yaml file
read_action_file() {
    local action_dir=$1
    if [[ -f "${action_dir}/action.yml" ]]; then
        echo "${action_dir}/action.yml"
    elif [[ -f "${action_dir}/action.yaml" ]]; then
        echo "${action_dir}/action.yaml"
    else
        echo ""
    fi
}

# Function to create or update import-config.yml for each action
create_or_update_import_config() {
    local group_dir=$1
    local action_dir=$2

    # Set initial values for import-config.yml
    group=$(basename "$group_dir")
    name=$(basename "$action_dir")

    # Determine the action file (either action.yml or action.yaml)
    action_file=$(read_action_file "${group_dir}/${action_dir}")

    if [[ -z "$action_file" ]]; then
        echo "No action.yml or action.yaml found in ${group_dir}/${action_dir}. Skipping..."
        return
    fi

    # Read first level keys of inputs, outputs, and runs from the action file
    inputs=$(yq e '.inputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    outputs=$(yq e '.outputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    runs_using=$(yq e '.runs.using' "$action_file")
    runs_main=$(yq e '.runs.main' "$action_file")

    import_config_file="${group_dir}/${action_dir}/import-config.yml"

    if [[ -f $import_config_file ]]; then
        echo ""
        echo "Updating ${import_config_file}..."

        # Read existing import-config.yml
        import_config=$(yq eval '.' "$import_config_file")

        # Update inputs and outputs fields
        import_config=$(echo "$import_config" | yq eval ".specs.inputs = [$inputs]" -)
        import_config=$(echo "$import_config" | yq eval ".specs.outputs = [$outputs]" -)

        # Update runs field if using and main are present
        if [[ -n $runs_using ]]; then
            import_config=$(echo "$import_config" | yq eval ".specs.runs.using = \"$runs_using\"" -)
            if [[ -n $runs_main ]]; then
                import_config=$(echo "$import_config" | yq eval ".specs.runs.main = \"$runs_main\"" -)
            else
                import_config=$(echo "$import_config" | yq eval "del(.specs.runs.main)" -)
            fi
        fi

        # Check for updates if imported
        if [[ $(echo "$import_config" | yq eval '.imported' -) == "true" ]]; then
            source_action_author=$(echo "$import_config" | yq eval '.source.author' -)
            source_repo_name=$(echo "$import_config" | yq eval '.source.repo_name' -)
            source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
            current_version=$(echo "$import_config" | yq eval '.source.current_version' -)
            latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi
            # Update source fields
            import_config=$(echo "$import_config" | yq eval ".source.latest_version = \"$latest_version\"" -)
            import_config=$(echo "$import_config" | yq eval ".source.update_available = $update_available" -)
        fi

        # Write updated import-config.yml file
        echo "$import_config" > "$import_config_file"
    else
        # Prompt the user to find out if the action is imported or locally-created
        read -p "Is the action in ${group_dir}/${action_dir} imported or locally-created (imported/local)? " action_type

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
            read -p "Have there been any local modifications? (true/false): " modifications
            read -p "Enter current version used: " current_version
            latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi
        else
            #read -p "Has there been any modifications? (true/false): " modifications
            modifications=true  # Setting modifications to true directly
        fi

        # Create import-config.yml content with name, description, group, and imported fields
        import_config=$(cat <<EOF
name: $name
description: ""
group: $group
imported: $imported
EOF
        )
        #

        # Add local and source blocks
        if [[ $imported == "true" ]]; then
            import_config+=$(
cat <<EOF

local:
  modifications: $modifications
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
        #

        # Add specs block, including inputs, outputs, and runs fields
        specs_block=$(cat <<EOF

specs:
  inputs: [$inputs]
  outputs: [$outputs]
EOF
        )
        if [[ -n $runs_using ]]; then
            specs_block+=$(cat <<EOF

  runs:
    using: "$runs_using"
EOF
            )
            if [[ -n $runs_main ]]; then
                specs_block+=$(cat <<EOF

    main: "$runs_main"
EOF
                )
            fi
        fi
        import_config+="$specs_block"

        # Add tests block to import-config.yml content
        import_config+=$(cat <<EOF

tests:
  _comment: "reserved for future use"
EOF
        )

        # Write import-config.yml file
        echo "$import_config" > "$import_config_file"
    fi

    # # Sort the import-config.yml file alphabetically
    # yq eval --inplace 'sort_keys(..)' "$import_config_file"

    echo "Processed import-config.yml for ${group_dir}/${action_dir}"
    echo ""
}

# Iterate through each group directory
for group_dir in "${target_dirs[@]}"; do
    for action_subdir in "$group_dir"/*; do
        if [[ -d "$action_subdir" ]]; then
            action_dir=$(basename "$action_subdir")
            create_or_update_import_config "$group_dir" "$action_dir"
        fi
    done
done
