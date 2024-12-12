#!/bin/bash

# Read target directories from the config file
target_dirs=($(cat target_dirs.conf))

# Function to create or update import-config.yml for each action
create_or_update_import_config() {
    local group_dir=$1
    local action_dir=$2

    # Set initial values for import-config.yml
    group=$(basename "$group_dir")
    name=$(basename "$action_dir")

    # Read first level keys of inputs, outputs, and runs from action.yml
    action_file="${group_dir}/${action_dir}/action.yml"
    inputs=$(yq e '.inputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    outputs=$(yq e '.outputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    runs_using=$(yq e '.runs.using' "$action_file")
    runs_main=$(yq e '.runs.main' "$action_file")

    import_config_file="${group_dir}/${action_dir}/import-config.yml"

    if [[ -f $import_config_file ]]; then
        echo "Updating ${import_config_file}..."

        # Read existing import-config.yml
        import_config=$(yq eval '.' $import_config_file)

        # Update inputs and outputs fields
        import_config=$(echo "$import_config" | yq eval ".inputs = [$inputs]" -)
        import_config=$(echo "$import_config" | yq eval ".outputs = [$outputs]" -)

        # Update runs field if using and main are present
        if [[ -n $runs_using && -n $runs_main ]]; then
            runs_block=$(cat <<EOF
runs:
  using: "$runs_using"
  main: "$runs_main"
EOF
            )
            import_config=$(echo "$import_config" | yq eval - <(echo "$runs_block"))
        elif [[ -n $runs_using ]]; then
            runs_block=$(cat <<EOF
runs:
  using: "$runs_using"
EOF
            )
            import_config=$(echo "$import_config" | yq eval - <(echo "$runs_block"))
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
            read -p "Enter current version used: " current_version
            latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi
        else
            #read -p "Has there been any modifications? (true/false): " modifications
            modifications=true
        fi

        # Create import-config.yml content
        import_config=$(cat <<EOF
imported: $imported
name: $name
description: ""
group: $group
inputs: [$inputs]
outputs: [$outputs]
tests:
  _comment: "reserved for future use"
EOF
        )

        # Add runs block if using and main are present
        if [[ -n $runs_using && -n $runs_main ]]; then
            import_config+=$(
cat <<EOF
runs:
  using: "$runs_using"
  main: "$runs_main"
EOF
            )
        elif [[ -n $runs_using ]]; then
            import_config+=$(
cat <<EOF
runs:
  using: "$runs_using"
EOF
            )
        fi

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
        echo "$import_config" > "$import_config_file"
    fi

    echo "Processed import-config.yml for ${group_dir}/${action_dir}"
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
