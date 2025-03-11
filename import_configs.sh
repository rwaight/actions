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

    if [[ "$specify_action" == "yes" && ( "$group" != "$specified_group" || "$name" != "$specified_action" ) ]]; then
        echo "Skipping $group/$name..."
        return
    fi

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

            # Prep the local template files
            local_repo_dir=$(pwd)
            template_file="$local_repo_dir/assets/imported_readme_template.md"

            # Create a temporary directory for downloading the updated source files
            temp_dir=$(mktemp -d)

            # Navigate to the temporary directory
            cd "$temp_dir" || exit

            # Clone the specific version of the repository
            git clone --branch "$latest_version" --depth 1 "$source_repo_url" .

            if [[ $? -eq 0 ]]; then
                echo "Downloaded updated source files to $temp_dir"

                # Copy the template file to the temp directory
                template_in_temp="$temp_dir/imported_readme_template.tempmd"
                cp "$template_file" "$template_in_temp"

                # Step 1: Rename the .github directory to __dot_github
                if [[ -d ".github" ]]; then
                    mv .github __dot_github
                fi

                # Step 2: Rename .yml files in __dot_github to have .disabled
                for f in __dot_github/*.yml; do
                    [ -e "$f" ] && mv "$f" "${f}.disabled"
                done

                # Step 3: Rename .yml files in __dot_github/workflows to have .disabled
                for f in __dot_github/workflows/*.yml; do
                    [ -e "$f" ] && mv "$f" "${f}.disabled"
                done

                # Step 4: Prepend repo_name to markdown files in top-level source directory
                for f in *.md; do
                    [ -e "$f" ] && mv "$f" "${source_repo_name}__$f"
                done

                # Step 5: Copy .yml files in top-level source directory with prepended repo_name
                for f in *.yml; do
                    [ -e "$f" ] && cp "$f" "${source_repo_name}__$f"
                done

                # Set the local action directory variable
                local_action_dir=$(dirname "$config_file")

                # Checkout main branch and create a new branch for the update
                #cd "$local_action_dir" || exit
                cd "$local_repo_dir" || exit
                git checkout main
                branch_name="updates/${group}_${name}_$(date +%Y%m)"
                git checkout -b "$branch_name"

                # Read exclusion list from import-config.yml
                exclusion_list=($(yq e '.local.update.exclusions[]' "$config_file" 2>/dev/null))

                # Always exclude import-config.yml
                exclusion_list+=("import-config.yml")
                
                # Convert the array into a pattern for `rm` exclusion
                exclusion_pattern=$(printf "! -name %s " "${exclusion_list[@]}")
                
                # print the list of files that will be excluded
                echo "The following files SHOULD BE excluded:"
                printf "%s\n" "${exclusion_list[@]}"
                echo ""

                # Clean up the $local_action_dir while keeping excluded files
                echo "Cleaning up $local_action_dir while keeping excluded files..."
                find "$local_action_dir" -mindepth 1 $exclusion_pattern -exec rm -rf {} +

                # print the list of excluded files
                echo "Cleanup completed. The following files were excluded:"
                printf "%s\n" "${exclusion_list[@]}"
                
                # Step 6: Move all processed files from temp directory to local action directory
                # Ensure dotfiles are included when copying from $temp_dir to $local_action_dir
                shopt -s dotglob  # Enable globbing for dotfiles
                cp -r "$temp_dir"/* "$local_action_dir"
                shopt -u dotglob  # Disable dotglob after use

                # Step 7: Create a new README.md from the template file
                #template_file="$local_repo_dir/assets/imported_readme_template.md"
                template_copied="$local_action_dir/imported_readme_template.tempmd"
                new_readme="$local_action_dir/README.md"
                if [[ -f "$template_copied" ]]; then
                    #cp "$template_file" "$new_readme"
                    mv "$template_copied" "$new_readme"

                    # Place for find/replace commands
                    sed -i "s/SED_GROUP/${group}/g" "$new_readme"
                    sed -i "s/SED_NAME/${name}/g" "$new_readme"
                    sed -i "s/SED_REPONAME/${source_repo_name}/g" "$new_readme"
                    sed -i "s/SED_REPOAUTH/${source_repo_author}/g" "$new_readme"
                    ##not used##sed -i "s/SED_REPOURL/${source_repo_url}/g" "$new_readme"
                    sed -i "s/SED_NEWVERSION/${latest_version}/g" "$new_readme"
                    sed -i "s/SED_NEWCOMMITSHA/${repo_latest_sha}/g" "$new_readme"
                    # Add additional find/replace commands as needed
                fi

                # Add changes to git and commit
                git add "$local_action_dir"
                echo "  Skipping running the 'git commit' command for now"
                echo ""
                echo "  Now you need to manually add the commit before continuing. "
                echo "  Recommended message:    chore($group): update $name to version $latest_version "
                #git commit -m "chore($group): update $name to version $latest_version"

                # Push the new branch to the remote repository
                echo ""
                echo "  Skipping running the 'git push origin \"$branch_name\"' command for now"
                #git push origin "$branch_name"
                echo "  you will need to push to origin later... "

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

# Prompt to specify whether to specify an action or use the target_dirs config file
read -p "Do you want to specify a group and action? (yes/no): " specify_action

if [[ "$specify_action" == "yes" ]]; then
    read -p "Enter the group name: " specified_group
    read -p "Enter the action name: " specified_action
fi

# Iterate through each target directory and check for updates
for target_dir in "${target_dirs[@]}"; do
    find "$target_dir" -name "import-config.yml" | while read -r config_file; do
        check_for_updates "$config_file"
    done
done
