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

    # Extract the action file extension
    action_file_extension=$(basename "$action_file")

    # Read first level keys of author, description, inputs, outputs, and runs from the action file
    author=$(yq e '.author' "$action_file")
    if [[ "$author" == "null" ]]; then unset author; fi
    description=$(yq e '.description' "$action_file")
    if [[ "$description" == "null" ]]; then unset description; fi
    inputs=$(yq e '.inputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    outputs=$(yq e '.outputs | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')
    runs_using=$(yq e '.runs.using' "$action_file")
    runs_main=$(yq e '.runs.main' "$action_file")
    if [[ "$runs_main" == "null" ]]; then unset runs_main; fi

    import_config_file="${group_dir}/${action_dir}/import-config.yml"

    if [[ -f $import_config_file ]]; then
        echo ""
        echo "Updating ${import_config_file}..."

        # Read existing import-config.yml
        import_config=$(yq eval '.' "$import_config_file")

        # Update author, description, specs.action_file, specs.inputs, and specs.outputs fields
        if [[ -n $author ]]; then
            yq e -i ".author = \"$author\"" "$import_config_file"
        else
            yq e -i ".author = \"placeholder\"" "$import_config_file"
        fi
        #
        if [[ -n $description ]]; then
            yq e -i ".description = \"$description\"" "$import_config_file"
        else
            yq e -i ".description = \"placeholder\"" "$import_config_file"
        fi
        yq e -i ".specs.action_file = \"$action_file_extension\"" "$import_config_file"
        yq e -i ".specs.inputs = [$inputs]" "$import_config_file"
        yq -i '.specs.inputs style="flow"' "$import_config_file"
        #import_config=$(echo "$import_config" | yq eval ".specs.inputs = [$inputs]" -)
        yq e -i ".specs.outputs = [$outputs]" "$import_config_file"
        yq -i '.specs.outputs style="flow"' "$import_config_file"
        #import_config=$(echo "$import_config" | yq eval ".specs.outputs = [$outputs]" -)

        # Update runs field if using and main are present
        if [[ -n $runs_using ]]; then
            yq e -i ".specs.runs.using = \"$runs_using\"" "$import_config_file"
            #import_config=$(echo "$import_config" | yq eval ".specs.runs.using = \"$runs_using\"" -)
            if [[ -n $runs_main ]]; then
                yq e -i ".specs.runs.main = \"$runs_main\"" "$import_config_file"
                #import_config=$(echo "$import_config" | yq eval ".specs.runs.main = \"$runs_main\"" -)
            else
                yq e -i "del(.specs.runs.main)" "$import_config_file"
                #import_config=$(echo "$import_config" | yq eval "del(.specs.runs.main)" -)
            fi
        fi

        # Check for updates if imported
        if [[ $(yq e '.imported' "$import_config_file") == "true" ]]; then
            source_action_author=$(yq e '.source.author' "$import_config_file")
            #source_action_author=$(echo "$import_config" | yq eval '.source.author' -)
            source_repo_name=$(yq e '.source.repo_name' "$import_config_file")
            #source_repo_name=$(echo "$import_config" | yq eval '.source.repo_name' -)
            source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
            current_version=$(yq e '.source.current_version' "$import_config_file")
            #current_version=$(echo "$import_config" | yq eval '.source.current_version' -)
            latest_version=$(curl -s "https://api.github.com/repos/${source_action_author}/${source_repo_name}/releases/latest" | jq -r .tag_name)
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi
            # Update source fields
            yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
            #import_config=$(echo "$import_config" | yq eval ".source.latest_version = \"$latest_version\"" -)
            yq e -i ".source.update_available = $update_available" "$import_config_file"
            #import_config=$(echo "$import_config" | yq eval ".source.update_available = $update_available" -)
        fi

    else
        # Prompt the user to find out if the action is imported or locally-created
        read -p "Is the action in ${group_dir}/${action_dir} imported or locally-created (imported/local)? " action_type

        # Set initial variables
        imported=false
        local_author="rwaight"
        modifications=false

        # Create an empty import-config.yml file
        touch "$import_config_file"

        # Set initial fields
        yq e -i ".name = \"$name\"" "$import_config_file"
        if [[ -n $author ]]; then
            yq e -i ".author = \"$author\"" "$import_config_file"
        else
            yq e -i ".author = \"placeholder\"" "$import_config_file"
        fi
        #
        if [[ -n $description ]]; then
            yq e -i ".description = \"$description\"" "$import_config_file"
        else
            yq e -i ".description = \"placeholder\"" "$import_config_file"
        fi
        yq e -i ".group = \"$group\"" "$import_config_file"
        yq e -i ".imported = false" "$import_config_file"

        # Add local and source blocks
        if [[ $action_type == "imported" ]]; then
            imported=true
            yq e -i ".imported = true" "$import_config_file"
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

            yq e -i ".local.modifications = $modifications" "$import_config_file"
            yq e -i ".source.action_name = \"$source_action_name\"" "$import_config_file"
            yq e -i ".source.author = \"$source_action_author\"" "$import_config_file"
            yq e -i ".source.repo_name = \"$source_repo_name\"" "$import_config_file"
            yq e -i ".source.repo_url = \"$source_repo_url\"" "$import_config_file"
            yq e -i ".source.current_version = \"$current_version\"" "$import_config_file"
            yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
            yq e -i ".source.update_available = $update_available" "$import_config_file"
        else
            yq e -i ".local.author = \"$local_author\"" "$import_config_file"
            yq e -i ".local.modifications = true" "$import_config_file"
        fi

        # Add specs block, including action_file, inputs, outputs, and runs fields
        yq e -i ".specs.action_file = \"$action_file_extension\"" "$import_config_file"
        yq e -i ".specs.inputs = [$inputs]" "$import_config_file"
        yq -i '.specs.inputs style="flow"' "$import_config_file"
        yq e -i ".specs.outputs = [$outputs]" "$import_config_file"
        yq -i '.specs.outputs style="flow"' "$import_config_file"
        if [[ -n $runs_using ]]; then
            yq e -i ".specs.runs.using = \"$runs_using\"" "$import_config_file"
            if [[ -n $runs_main ]]; then
                yq e -i ".specs.runs.main = \"$runs_main\"" "$import_config_file"
            fi
        fi

        # Add tests block
        yq e -i ".tests._comment = \"reserved for future use\"" "$import_config_file"
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
