#!/bin/bash

# Read target directories from the config file
target_dirs=($(cat target_dirs.conf))

# Function to read the import-config.yml file and check for updates
check_for_updates() {
    local config_file=$1

    if [[ ! -f "$config_file" ]]; then
        echo "No import-config.yml found in $config_file. Skipping..."
        return
    fi

    imported=$(yq e '.imported' "$config_file")

    if [[ "$imported" == "true" ]]; then
        source_repo_url=$(yq e '.source.repo_url' "$config_file")
        current_version=$(yq e '.source.current_version' "$config_file")
        latest_version=$(yq e '.source.latest_version' "$config_file")
        update_available=$(yq e '.source.update_available' "$config_file")

        if [[ "$update_available" == "true" ]]; then
            echo "Update available for $config_file"
            echo "Downloading updated source files for version $latest_version..."

            # Create a temporary directory for downloading the updated source files
            temp_dir=$(mktemp -d)

            # Clone the specific version of the repository
            git clone --branch "$latest_version" --depth 1 "$source_repo_url" "$temp_dir"

            if [[ $? -eq 0 ]]; then
                echo "Downloaded updated source files to $temp_dir"

                # Copy the downloaded files to the local action directory
                local_action_dir=$(dirname "$config_file")
                cp -r "$temp_dir"/* "$local_action_dir"

                # Clean up the temporary directory
                rm -rf "$temp_dir"

                # Update the current version in import-config.yml
                yq e -i ".source.current_version = \"$latest_version\"" "$config_file"
                yq e -i ".source.update_available = false" "$config_file"

                echo "Updated local version of the action in $local_action_dir"
            else
                echo "Failed to download the updated source files for $config_file"
            fi
        else
            echo "No update available for $config_file"
        fi
    else
        echo "Action in $config_file is not imported. Skipping..."
    fi
}

# Iterate through each target directory and check for updates
for target_dir in "${target_dirs[@]}"; do
    find "$target_dir" -name "import-config.yml" | while read -r config_file; do
        check_for_updates "$config_file"
    done
done
