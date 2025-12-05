#!/bin/bash

# Define the error log file
error_log="monorepo_updates_errors.log"
> "$error_log"  # Clear the log file at the start

# Read target directories from the config file
mapfile -t target_dirs < target_dirs.conf

# Function to fetch the latest version from GitHub API
function fetch_latest_version() {
    local repo_owner="$1"
    local repo_name="$2"
    #
    # using 'curl' with the GitHub API now requires an access token
    ##latest_version=$(curl -s "https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest" | jq -r .tag_name)
    # use 'gh release' or 'gh api' to fetch the latest version
    # https://docs.github.com/rest/releases/releases#get-the-latest-release
    # https://cli.github.com/manual/gh_release_list
    latest_version=$(gh release list --json name,tagName,isLatest --jq '.[] | select(.isLatest)|.tagName' --repo "${repo_owner}/${repo_name}")
    # gh cli command ##latest_version=$(gh release list --json name,tagName,isLatest --jq '.[] | select(.isLatest)|.tagName' --repo "${repo_owner}/${repo_name}")
    # gh api command ##latest_version=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${repo_owner}/${repo_name}/releases/latest")
    #
    if [[ "$latest_version" == "null" || -z "$latest_version" ]]; then
        echo "[ERROR] Unable to fetch latest version for $repo_owner/$repo_name" >> "$error_log"
        latest_version="error"
    fi
    #
    echo "$latest_version"
}

# Function to read the action.yml or action.yaml file
function read_action_file() {
    local action_dir=$1
    if [[ -f "${action_dir}/action.yml" ]]; then
        echo "${action_dir}/action.yml"
    elif [[ -f "${action_dir}/action.yaml" ]]; then
        echo "${action_dir}/action.yaml"
    else
        echo ""
    fi
}

# Function to read the import-config.yml file and check for updates
check_for_updates() {
    local config_file=$1

    if [[ ! -f "$config_file" ]]; then
        echo "No import-config.yml found in $config_file. Skipping..."
        return
    fi

    group=$(yq e '.group' "$config_file")
    name=$(yq e '.name' "$config_file")

    specify_action_lower=$(echo "$specify_action" | tr '[:upper:]' '[:lower:]')
    if [[ "$specify_action_lower" =~ ^(yes|y)$ && ( "$group" != "$specified_group" || "$name" != "$specified_action" ) ]]; then
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
        #
        echo "  Checking for updates from $source_repo_author/$source_repo_name ..."
        # use the 'fetch_latest_version' function instead ## latest_version=$(yq e '.source.latest_version' "$config_file")
        latest_version=$(fetch_latest_version "$source_repo_author" "$source_repo_name")
        # do not get 'update_available' from the config file ## update_available=$(yq e '.source.update_available' "$config_file")
        if [[ $current_version != $latest_version ]]; then
            update_available=true
        else
            update_available=false
        fi
        # update the 'update_available' value in the config file
        yq e -i ".source.update_available = $update_available" "$config_file"
        #
        if [[ "$update_available" == "true" ]]; then
            echo "  Update available for $group/$name "
            # using 'curl' with the GitHub API now requires an access token #
            ##repo_latest_tag=$(curl -s "https://api.github.com/repos/${source_repo_author}/${source_repo_name}/releases/latest" | jq -r '.tag_name')
            ##repo_latest_tag_data=$(curl -s "https://api.github.com/repos/${source_repo_author}/${source_repo_name}/git/ref/tags/${repo_latest_tag}" | jq -r '.object.type,.object.sha')
            # using 'curl' with the GitHub API now requires an access token #
            # use 'gh api' to fetch the reference from the latest tag
            # https://docs.github.com/en/rest/git/refs?apiVersion=2022-11-28#get-a-reference
            # https://cli.github.com/manual/gh_api
            # gh api command ##gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${source_repo_author}/${source_repo_name}/git/ref/tags/${latest_version}"
            # store the entire json response in a variable #
            json_latest_ref=$(gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/${source_repo_author}/${source_repo_name}/git/ref/tags/${latest_version}")test_version}")
            latest_tag_ref=$(echo "$json_latest_ref" | jq -r '.ref')
            latest_tag_url=$(echo "$json_latest_ref" | jq -r '.url')
            #repo_latest_sha_type=${repo_latest_tag_data%$'\n'*}
            latest_tag_type=$(echo "$json_latest_ref" | jq -r '.object.type')
            #repo_latest_sha=${repo_latest_tag_data##*$'\n'}
            latest_tag_sha=$(echo "$json_latest_ref" | jq -r '.object.sha')
            latest_tag_sha_url=$(echo "$json_latest_ref" | jq -r '.object.url')
            #
            echo "Downloading updated source files for version $latest_version..."
            #
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
                    sed -i '' "s/SED_GROUP/${group}/g" "$new_readme"
                    sed -i '' "s/SED_NAME/${name}/g" "$new_readme"
                    sed -i '' "s/SED_REPONAME/${source_repo_name}/g" "$new_readme"
                    sed -i '' "s/SED_REPOAUTH/${source_repo_author}/g" "$new_readme"
                    ##not used##sed -i '' "s/SED_REPOURL/${source_repo_url}/g" "$new_readme"
                    sed -i '' "s/SED_NEWVERSION/${latest_version}/g" "$new_readme"
                    sed -i '' "s/SED_NEWCOMMITSHA/${latest_tag_sha}/g" "$new_readme"
                    # Add additional find/replace commands as needed
                fi

                # Step 8: Update branding color in action.yml file to always be 'blue'
                action_file=$(read_action_file "${local_action_dir}")
                if [[ -n "$action_file" ]]; then
                    echo "Updating branding color in action file..."
                    # Check if branding block exists
                    branding_exists=$(yq e '.branding' "$action_file")
                    if [[ "$branding_exists" != "null" ]]; then
                        # Update color to blue, preserving the icon
                        yq e -i '.branding.color = "blue"' "$action_file"
                        echo "  Updated branding.color to 'blue' in $action_file"
                    else
                        echo "  No branding block found in $action_file, skipping branding update"
                    fi
                fi

                # Add changes to git and commit
                git add "$local_action_dir"
                echo ""
                commit_message="chore($group): update $name to version $latest_version"
                echo "  Recommended commit message: $commit_message"
                echo ""
                read -p "Do you want to commit these changes to the branch? (y/n): " commit_changes
                commit_changes_lower=$(echo "$commit_changes" | tr '[:upper:]' '[:lower:]')
                
                if [[ "$commit_changes_lower" =~ ^(yes|y)$ ]]; then
                    git commit -m "$commit_message"
                    echo "  Changes committed successfully"
                else
                    echo "  Skipping commit. You will need to manually commit changes before pushing."
                fi

                # Push the new branch to the remote repository
                echo ""
                # echo "  Skipping running the 'git push origin \"$branch_name\"' command for now"
                # #git push origin "$branch_name"
                # echo "  you will need to push to origin later... "
                echo "  Note: Automatic push is disabled. You will need to push to origin manually."
                echo "  To push, run: git push origin \"$branch_name\""

                # Clean up the temporary directory
                read -p "Do you want to clean up the temporary directory $temp_dir? (y/n): " cleanup
                cleanup_lower=$(echo "$cleanup" | tr '[:upper:]' '[:lower:]')
                if [[ "$cleanup_lower" =~ ^(yes|y)$ ]]; then
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
specify_action_lower=$(echo "$specify_action" | tr '[:upper:]' '[:lower:]')

if [[ "$specify_action_lower" =~ ^(yes|y)$ ]]; then
    read -p "Enter the group name: " specified_group
    read -p "Enter the action name: " specified_action
fi

# Iterate through each target directory and check for updates
for target_dir in "${target_dirs[@]}"; do
    find "$target_dir" -name "import-config.yml" | while read -r config_file; do
        check_for_updates "$config_file"
    done
done
