#!/bin/bash

# Define the error log file
error_log="import_configs_errors.log"
> "$error_log"  # Clear the log file at the start

# Print yq and jq versions for debugging
echo "Running yq version: $(yq --version 2>&1)" | tee -a "$error_log"
echo "Running jq version: $(jq --version 2>&1)" | tee -a "$error_log"

# Read target directories from the config file
target_dirs=($(cat target_dirs.conf))

# Default exclusions array
default_exclusions=("README-examples.md" "example-custom-notes.md")

# Array to track errors
error_actions=()

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

# Function to sanitize values (removes backticks to avoid parsing issues)
sanitize_value() {
    local value="$1"
    if [[ "$value" == *"\`"* ]]; then
        echo "[WARNING] Backticks found in value: $value" | tee -a "$error_log"
        value="${value//\`/}"  # Remove backticks
    fi
    echo "$value"
}

# Function to fetch the latest version from GitHub API
fetch_latest_version() {
    local author="$1"
    local repo="$2"
    
    latest_version=$(curl -s "https://api.github.com/repos/${author}/${repo}/releases/latest" | jq -r .tag_name)
    
    if [[ "$latest_version" == "null" || -z "$latest_version" ]]; then
        echo "[ERROR] Unable to fetch latest version for $author/$repo" | tee -a "$error_log"
        latest_version=""
    fi
    
    echo "$latest_version"
}

# Function to create or update import-config.yml for each action
create_or_update_import_config() {
    local group_dir=$1
    local action_dir=$2
    local import_config_file="${group_dir}/${action_dir}/import-config.yml"

    echo "Processing: Group = $group_dir, Action = $action_dir"

    action_file=$(read_action_file "${group_dir}/${action_dir}")
    if [[ -z "$action_file" ]]; then
        echo "[ERROR] No action.yml or action.yaml found in ${group_dir}/${action_dir}. Skipping..." | tee -a "$error_log"
        return
    fi

    # Extract the action file extension
    action_file_extension=$(basename "$action_file")

    # Read required fields from action file while filtering out null values
    {
        author=$(sanitize_value "$(yq e '.author // "placeholder"' "$action_file" 2>/dev/null)")
        description=$(sanitize_value "$(yq e '.description // "placeholder"' "$action_file" 2>/dev/null)")
        inputs=$(sanitize_value "$(yq e '.inputs | select(. != null) | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')")
        outputs=$(sanitize_value "$(yq e '.outputs | select(. != null) | keys' "$action_file" | sed 's/- /"/g; s/$/",/' | tr -d '\n' | sed 's/,$//')")
        runs_using=$(sanitize_value "$(yq e '.runs.using // empty' "$action_file" 2>/dev/null)")
        runs_main=$(sanitize_value "$(yq e '.runs.main // empty' "$action_file" 2>/dev/null)")
    } || {
        echo "[ERROR] A general issue occurred while reading fields in $action_file" | tee -a "$error_log"
        error_actions+=("${group_dir}/${action_dir}")
        return
    }

    if [[ -f $import_config_file ]]; then
        echo "Updating ${import_config_file}..."

        # Check for updates if imported
        if [[ $(yq e '.imported' "$import_config_file") == "true" ]]; then
            source_author=$(yq e '.source.author' "$import_config_file")
            source_repo=$(yq e '.source.repo_name' "$import_config_file")
            current_version=$(yq e '.source.current_version' "$import_config_file")

            latest_version=$(fetch_latest_version "$source_author" "$source_repo")

            if [[ -n "$latest_version" && "$current_version" != "$latest_version" ]]; then
                yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
                yq e -i ".source.update_available = true" "$import_config_file"
                echo "[UPDATE] New version available for $source_repo: $latest_version" | tee -a "$error_log"
            else
                yq e -i ".source.update_available = false" "$import_config_file"
            fi
        fi

    else
        echo "[INFO] Creating new ${import_config_file}..."
        touch "$import_config_file"

        # Ask user if action is imported or locally created
        read -p "Is the action in ${group_dir}/${action_dir} imported or locally created? (imported/local): " action_type

        if [[ $action_type == "imported" ]]; then
            imported=true
            yq e -i ".imported = true" "$import_config_file"
            
            read -p "Enter source action name [default: $action_dir]: " source_action_name
            source_action_name=${source_action_name:-$action_dir}
            
            read -p "Enter source action author: " source_action_author
            read -p "Enter source GitHub repo name [default: $action_dir]: " source_repo_name
            source_repo_name=${source_repo_name:-$action_dir}
            
            source_repo_url="https://github.com/${source_action_author}/${source_repo_name}"
            read -p "Have there been any local modifications? (true/false): " modifications
            read -p "Enter current version used: " current_version
            
            latest_version=$(fetch_latest_version "$source_action_author" "$source_repo_name")
            update_available=false
            if [[ $current_version != $latest_version ]]; then
                update_available=true
            fi

            yq e -i ".source.action_name = \"$source_action_name\"" "$import_config_file"
            yq e -i ".source.author = \"$source_action_author\"" "$import_config_file"
            yq e -i ".source.repo_name = \"$source_repo_name\"" "$import_config_file"
            yq e -i ".source.repo_url = \"$source_repo_url\"" "$import_config_file"
            yq e -i ".source.current_version = \"$current_version\"" "$import_config_file"
            yq e -i ".source.latest_version = \"$latest_version\"" "$import_config_file"
            yq e -i ".source.update_available = $update_available" "$import_config_file"
            yq e -i ".local.modifications = $modifications" "$import_config_file"

        else
            yq e -i ".imported = false" "$import_config_file"
            yq e -i ".local.author = \"local_user\"" "$import_config_file"
            yq e -i ".local.modifications = true" "$import_config_file"
        fi

        yq e -i ".local.update.exclusions = [\"README-examples.md\", \"example-custom-notes.md\"]" "$import_config_file"
    fi

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

echo "[INFO] Finished processing. Check $error_log for error details."
