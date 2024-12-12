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
        source_repo_name=$(yq e '.source.repo_name' "$config_file")
        source_repo_author=$(yq e '.source.author' "$config_file")
        current_version=$(yq e '.source.current_version' "$config_file")
        latest_version=$(yq e '.source.latest_version' "$config_file")
        update_available=$(yq e '.source.update_available' "$config_file")

        echo "Checking for updates from $source_repo_url..."

        if [[ "$update_available" == "true" ]]; then
            echo "Update available for $config_file"
            repo_latest_tag=$(curl -s "https://api.github.com/repos/${source_repo_author}/${source_repo_name}/releases/latest" | jq -r '.tag_name')
            repo_latest_tag_data=$(curl -s "https://api.github.com/repos/${source_repo_author}/${source_repo_name}/git/ref/tags/${repo_latest_tag}" | jq -r '.object.type,.object.sha')
            repo_latest_sha_type=${repo_latest_tag_data%$'\n'*}
            repo_latest_sha=${repo_latest_tag_data##*$'\n'}
            echo "Downloading updated source files for version $latest_version..."

            # Create a temporary directory for downloading the updated source files
            temp_dir=$(mktemp -d)

            # Clone the specific version of the repository
            git clone --branch "$latest_version" --depth 1 "$source_repo_url" "$temp_dir"

            if [[ $? -eq 0 ]]; then
                echo "Downloaded updated source files to $temp_dir"

                # Step 1: Rename the .github directory to __dot_github
                if [[ -d "$temp_dir/.github" ]]; then
                    mv "$temp_dir/.github" "$temp_dir/__dot_github"
                fi

                # Step 2: Rename .yml files in __dot_github to have .disabled
                for f in "$temp_dir/__dot_github"/*.yml; do
                    [ -e "$f" ] && mv "$f" "$f.disabled"
                done

                # Step 3: Rename .yml files in __dot_github/workflows to have .disabled
                for f in "$temp_dir/__dot_github/workflows"/*.yml; do
                    [ -e "$f" ] && mv "$f" "$f.disabled"
                done

                # Step 4: Prepend repo_name to markdown files in top-level source directory
                for f in "$temp_dir"/*.md; do
                    [ -e "$f" ] && mv "$f" "${source_repo_name}__$f"
                done

                # Step 5: Copy .yml files in top-level source directory with prepended repo_name
                for f in "$temp_dir"/*.yml; do
                    [ -e "$f" ] && cp "$f" "${source_repo_name}__$f"
                done

                # Set the local action directory variable
                local_action_dir=$(dirname "$config_file")

                # Checkout main branch and create a new branch for the update
                cd "$local_action_dir" || exit
                git checkout main
                branch_name="updates/${group}_${name}_$(date +%Y%m)"
                git checkout -b "$branch_name"

                # Step 6: Move all processed files from temp directory to local action directory
                cp -r "$temp_dir"/* "$local_action_dir"

                # Step 7: Create a new README.md from the template file
                template_file="$local_action_dir/assets/imported_readme_template.md"
                new_readme="$local_action_dir/README.md"
                if [[ -f "$template_file" ]]; then
                    cp "$template_file" "$new_readme"

                    # Place for find/replace commands
                    sed -i "s/SED_GROUP/$group/g" "$new_readme"
                    sed -i "s/SED_NAME/$name/g" "$new_readme"
                    sed -i "s/SED_REPONAME/$source_repo_name/g" "$new_readme"
                    sed -i "s/SED_REPOAUTH/$source_repo_author/g" "$new_readme"
                    sed -i "s/SED_REPOURL/$source_repo_url/g" "$new_readme"
                    sed -i "s/SED_NEWVERSION/$latest_version/g" "$new_readme"
                    sed -i "s/SED_NEWCOMMITSHA/$repo_latest_sha/g" "$new_readme"
                    # Add additional find/replace commands as needed
                fi

                # Add changes to git and commit
                git add "$local_action_dir"
                git commit -m "Update action $group/$name to version $latest_version"

                # Push the new branch to the remote repository
                git push origin "$branch_name"

                # Clean up the temporary directory
                read -p "Do you want to clean up the temporary directory $temp_dir? (y/n): " cleanup
                if [[ $cleanup == "y" ]]; then
                    rm -rf "$temp_dir"
                fi

                # Update the current version in import-config.yml
                yq e -i ".source.current_version = \"$latest_version\"" "$config_file"
                yq e -i ".source.update_available = false" "$config_file"

                echo "Updated local version of the action in $local_action_dir"
                echo "Created a new branch $branch_name for the update"
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
