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

    group=$(yq e '.group' "$config_file")
    name=$(yq e '.name' "$config_file")

    echo "Processing $group/$name..."

    imported=$(yq e '.imported' "$config_file")

    if [[ "$imported" == "true" ]]; then
        source_repo_url=$(yq e '.source.repo_url' "$config_file")
        current_version=$(yq e '.source.current_version' "$config_file")
        latest_version=$(yq e '.source.latest_version' "$config_file")
        update_available=$(yq e '.source.update_available' "$config_file")

        echo "Checking for updates from $source_repo_url..."

        if [[ "$update_available" == "true" ]]; then
            echo "Update available for $config_file"
            echo "Downloading updated source files for version $latest_version..."

            # Create a temporary directory for downloading the updated source files
            temp_dir=$(mktemp -d)
            cd "$temp_dir" || exit

            # Clone the specific version of the repository
            #git clone --branch "$latest_version" --depth 1 "$source_repo_url" "$temp_dir"
            git clone --branch "$latest_version" --depth 1 "$source_repo_url" .

            if [[ $? -eq 0 ]]; then
                echo "Downloaded updated source files to $temp_dir"

                # Step 1: Rename the .github directory to __dot_github
                if [[ -d ".github" ]]; then
                    mv .github __dot_github
                fi

                # Step 2: Rename .yml files in __dot_github to have .disabled
                for f in __dot_github/*.yml; do
                    [ -e "$f" ] && mv "$f" "$f.disabled"
                done

                # Step 3: Rename .yml files in __dot_github/workflows to have .disabled
                for f in __dot_github/workflows/*.yml; do
                    [ -e "$f" ] && mv "$f" "$f.disabled"
                done

                # Step 4: Prepend repo_name to markdown files in top-level source directory
                for f in *.md; do
                    [ -e "$f" ] && mv "$f" "${source_repo_name}__$f"
                done

                # Step 5: Copy .yml files in top-level source directory with prepended repo_name
                for f in *.yml; do
                    [ -e "$f" ] && cp "$f" "${source_repo_name}__$f"
                done

                # Step 6: Move all processed files from temp directory to local action directory
                local_action_dir=$(dirname "$config_file")
                cp -r "$temp_dir"/* "$local_action_dir"

                # Step 7: Create a new README.md from the template file
                template_file="$local_action_dir/assets/imported_readme_template.md"
                new_readme="$local_action_dir/README.md"
                if [[ -f "$template_file" ]]; then
                    cp "$template_file" "$new_readme"

                    # Place for find/replace commands
                    sed -i "s/{{GROUP}}/$group/g" "$new_readme"
                    sed -i "s/{{NAME}}/$name/g" "$new_readme"
                    # Add additional find/replace commands as needed
                fi

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
