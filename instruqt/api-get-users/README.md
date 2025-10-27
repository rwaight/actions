# Instruqt Get Users Action

Use Instruqt API to get a list of users and their information.

This action interacts with the Instruqt GraphQL API to:

1. Get team information
2. List all users in the team
3. Get detailed information about each user
4. Save results to files and environment variables for further use in GitHub Actions
5. Print a summary of users found

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `api-key` | The API key to authenticate with the Instruqt API | true | - |
| `team-workspace` | The team workspace slug to get users from | true | - |
| `verbose` | Determine if the action should run verbose tasks | false | `false` |

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.

| Output | Description |
|--------|-------------|
| `users-json` | A JSON string containing user information (only available if under 1MB size limit) |
| `users-json-available` | Whether the users JSON is available in outputs (true/false) |
| `total-users` | Total number of users found |
| `total-owners` | Total number of users with owner role |
| `total-members` | Total number of users with member role |
| `total-content-creators` | Total number of users with content_creator role |
| `total-instructors` | Total number of users with instructor role |

> **Note**: If the users JSON exceeds GitHub's 1MB output size limit, it will not be available in the `users-json` output. Check `users-json-available` to determine availability, and use the `team_users_details.json` artifact file instead.

GitHub Actions has limits for individual step outputs as well as limits for the total size of all outputs in a workflow run (see [Usage limits documentation](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits)). This action intelligently handles these constraints by checking the JSON data size before attempting to export it as an output. When the data exceeds the limit, the action sets `users-json-available` to `false` and directs users to the artifact files instead, ensuring reliable operation regardless of dataset size.

## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:

```yml
name: Get Instruqt Users

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  get-users:
    runs-on: ubuntu-latest
    name: Get Instruqt Users
    steps:
      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Instruqt users
        id: get-users
        uses: rwaight/actions/instruqt/api-get-users@main
        with:
          api-key: ${{ secrets.INSTRUQT_API_KEY }}
          team-workspace: ${{ vars.INSTRUQT_TEAM_WORKSPACE }}
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Print user counts
        run: |
          echo "Total users: ${{ steps.get-users.outputs.total-users }}"
          echo "Owners: ${{ steps.get-users.outputs.total-owners }}"
          echo "Members: ${{ steps.get-users.outputs.total-members }}"
          echo "Content Creators: ${{ steps.get-users.outputs.total-content-creators }}"
          echo "Instructors: ${{ steps.get-users.outputs.total-instructors }}"

      - name: Print user information (if available)
        if: steps.get-users.outputs.users-json-available == 'true'
        run: |
          echo "User information:"
          echo '${{ steps.get-users.outputs.users-json }}' | jq '.'

      - name: Use artifact file (if JSON too large)
        if: steps.get-users.outputs.users-json-available == 'false'
        run: |
          echo "Users JSON too large for output, using artifact file instead"
          cat team_users_details.json | jq '.'
```

### Advanced Example

```yml
name: Process Instruqt Users

on:
  schedule:
    - cron: '0 8 * * MON'  # Run every Monday at 8 AM
  workflow_dispatch:

jobs:
  process-users:
    runs-on: ubuntu-latest
    name: Process Instruqt Users
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Instruqt users
        id: get-users
        uses: rwaight/actions/instruqt/api-get-users@main
        with:
          api-key: ${{ secrets.INSTRUQT_API_KEY }}
          team-workspace: ${{ vars.INSTRUQT_TEAM_WORKSPACE }}
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Display user summary
        run: |
          echo "### User Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "- **Total Users**: ${{ steps.get-users.outputs.total-users }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Owners**: ${{ steps.get-users.outputs.total-owners }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Members**: ${{ steps.get-users.outputs.total-members }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Content Creators**: ${{ steps.get-users.outputs.total-content-creators }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Instructors**: ${{ steps.get-users.outputs.total-instructors }}" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "- **JSON Output Available**: ${{ steps.get-users.outputs.users-json-available }}" >> $GITHUB_STEP_SUMMARY

      - name: Process user data from output
        if: steps.get-users.outputs.users-json-available == 'true'
        run: |
          # Parse the JSON output and extract user roles summary
          echo '${{ steps.get-users.outputs.users-json }}' | jq -r '
            group_by(.role) | 
            map({
              role: .[0].role,
              count: length,
              users: map(.display_name)
            }) | 
            .[] | 
            "\(.role): \(.count) users - \(.users | join(", "))"
          ' > user-roles-report.txt
          #
          echo "User Roles Report:"
          cat user-roles-report.txt

      - name: Process user data from file
        if: steps.get-users.outputs.users-json-available == 'false'
        run: |
          # Use the JSON file when output is too large
          cat team_users_details.json | jq -r '
            group_by(.role) | 
            map({
              role: .[0].role,
              count: length,
              users: map(.display_name)
            }) | 
            .[] | 
            "\(.role): \(.count) users - \(.users | join(", "))"
          ' > user-roles-report.txt
          #
          echo "User Roles Report (from file):"
          cat user-roles-report.txt

      - name: Create detailed reports
        run: |
          # Determine source of user data
          if [ "${{ steps.get-users.outputs.users-json-available }}" == "true" ]; then
            USERS_DATA='${{ steps.get-users.outputs.users-json }}'
          else
            USERS_DATA=$(cat team_users_details.json)
          fi
          
          # Extract users by email domain
          echo "$USERS_DATA" | jq -r '
            map(select(.email != "No Email")) |
            map(.email | split("@")[1]) |
            group_by(.) |
            map({
              domain: .[0],
              count: length
            }) |
            sort_by(-.count) |
            .[] |
            "\(.domain): \(.count) users"
          ' > user-domains-report.txt
          #
          echo "User Email Domains Report:"
          cat user-domains-report.txt
          #
          # Create CSV export of users
          echo "Name,Email,Role,Scope,Anonymous,Avatar" > users-export.csv
          echo "$USERS_DATA" | jq -r '
            .[] |
            [.display_name, .email, .role, .scope, .is_anonymous, .avatar] |
            @csv
          ' >> users-export.csv
          #
          echo "Created CSV export with $(wc -l < users-export.csv) lines (including header)"
        shell: bash

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: users-report
          path: |
            team_users_list.txt
            team_users_details.json
            user-roles-report.txt
            user-domains-report.txt
            users-export.csv

      - name: Create summary
        run: |
          {
            echo "# Instruqt Users Report"
            echo ""
            echo "## Team Summary"
            echo "- **Total Users**: ${{ steps.get-users.outputs.total-users }}"
            echo "- **Owners**: ${{ steps.get-users.outputs.total-owners }}"
            echo "- **Members**: ${{ steps.get-users.outputs.total-members }}"
            echo "- **Content Creators**: ${{ steps.get-users.outputs.total-content-creators }}"
            echo "- **Instructors**: ${{ steps.get-users.outputs.total-instructors }}"
            echo ""
            
            # Determine source and add appropriate note
            if [ "${{ steps.get-users.outputs.users-json-available }}" == "true" ]; then
              USERS_DATA='${{ steps.get-users.outputs.users-json }}'
              echo "_Data source: Action output_"
            else
              USERS_DATA=$(cat team_users_details.json)
              echo "_Data source: Artifact file (output too large)_"
            fi
            
            echo ""
            echo "## Users by Role"
            echo "$USERS_DATA" | jq -r '
              group_by(.role) | 
              map("- **\(.[0].role)**: \(length) users") |
              .[]
            '
            echo ""
            echo "## Top Email Domains"
            echo "$USERS_DATA" | jq -r '
              map(select(.email != "No Email")) |
              map(.email | split("@")[1]) |
              group_by(.) |
              map({domain: .[0], count: length}) |
              sort_by(-.count) |
              .[0:5] |
              map("- **\(.domain)**: \(.count) users") |
              .[]
            '
          } >> $GITHUB_STEP_SUMMARY
        shell: bash
```

### Conditional Processing Example

```yml
name: User Audit and Notifications

on:
  workflow_dispatch:
    inputs:
      notify_inactive:
        description: 'Send notifications for inactive users'
        required: false
        default: 'false'
        type: boolean

jobs:
  audit-users:
    runs-on: ubuntu-latest
    name: Audit Instruqt Users
    steps:

      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Instruqt users
        id: get-users
        uses: rwaight/actions/instruqt/api-get-users@main
        with:
          api-key: ${{ secrets.INSTRUQT_API_KEY }}
          team-workspace: ${{ vars.INSTRUQT_TEAM_WORKSPACE }}
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Check content creator count using output
        if: steps.get-users.outputs.total-content-creators > 10
        run: |
          echo "::warning::High number of content creators detected: ${{ steps.get-users.outputs.total-content-creators }}"

      - name: Analyze user data
        id: analyze
        run: |
          # Determine source of user data
          if [ "${{ steps.get-users.outputs.users-json-available }}" == "true" ]; then
            users_json='${{ steps.get-users.outputs.users-json }}'
          else
            users_json=$(cat team_users_details.json)
          fi
          
          # Count anonymous users
          anonymous_count=$(echo "$users_json" | jq '[.[] | select(.is_anonymous == true)] | length')
          echo "anonymous_users=$anonymous_count" >> $GITHUB_OUTPUT
          #
          # Check for users without email
          no_email_count=$(echo "$users_json" | jq '[.[] | select(.email == "No Email")] | length')
          echo "users_no_email=$no_email_count" >> $GITHUB_OUTPUT
        shell: bash

      - name: Create issue for anonymous users
        if: steps.analyze.outputs.anonymous_users > 0
        uses: actions/github-script@v7
        with:
          script: |
            let anonymousUsers;
            
            if ('${{ steps.get-users.outputs.users-json-available }}' === 'true') {
              const usersData = ${{ steps.get-users.outputs.users-json }};
              anonymousUsers = usersData
                .filter(user => user.is_anonymous === true)
                .map(user => `- ${user.display_name} (${user.email})`)
                .join('\n');
            } else {
              const fs = require('fs');
              const usersData = JSON.parse(fs.readFileSync('team_users_details.json', 'utf8'));
              anonymousUsers = usersData
                .filter(user => user.is_anonymous === true)
                .map(user => `- ${user.display_name} (${user.email})`)
                .join('\n');
            }
            
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Found ${{ steps.analyze.outputs.anonymous_users }} anonymous users in Instruqt team`,
              body: `## Anonymous Users Detected\n\nThe following users are marked as anonymous:\n\n${anonymousUsers}\n\n**Action Required**: Review these accounts and determine if they should be converted to regular user accounts.`,
              labels: ['instruqt', 'user-audit', 'anonymous-users']
            });

      - name: Notify about content creators
        if: steps.get-users.outputs.total-content-creators > 10
        run: |
          echo "::warning::High number of content creators detected: ${{ steps.get-users.outputs.total-content-creators }}"
          echo "Consider reviewing content creator permissions for security purposes."
        shell: bash
```

## Output Size Considerations

The action includes smart handling for large datasets:

- **JSON Output**: Available via `users-json` output only if data is under 1MB
- **Availability Flag**: Check `users-json-available` to determine if JSON is in outputs
- **Artifact Files**: Always generated regardless of size:
  - `team_users_list.txt` - Human-readable user list
  - `team_users_details.json` - Complete JSON data
- **Count Outputs**: Always available regardless of dataset size:
  - `total-users`
  - `total-owners`
  - `total-members`
  - `total-content-creators`
  - `total-instructors`

When processing large user datasets, use the conditional logic shown in the advanced examples to automatically fall back to artifact files when needed.
