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
| `users-json` | A JSON string containing user information |

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
          team-workspace: 'my-team'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Print user information
        run: |
          echo "User information:"
          echo '${{ steps.get-users.outputs.users-json }}' | jq '.'
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

      - name: Process user data
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
          #
          # Extract users by email domain
          echo '${{ steps.get-users.outputs.users-json }}' | jq -r '
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
          echo '${{ steps.get-users.outputs.users-json }}' | jq -r '
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
            total_users=$(echo '${{ steps.get-users.outputs.users-json }}' | jq '. | length')
            echo "- **Total Users**: $total_users"
            echo ""
            echo "## Users by Role"
            echo '${{ steps.get-users.outputs.users-json }}' | jq -r '
              group_by(.role) | 
              map("- **\(.[0].role)**: \(length) users") |
              .[]
            '
            echo ""
            echo "## Top Email Domains"
            echo '${{ steps.get-users.outputs.users-json }}' | jq -r '
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

      - name: Analyze user data
        id: analyze
        run: |
          users_json='${{ steps.get-users.outputs.users-json }}'
          #
          # Count anonymous users
          anonymous_count=$(echo "$users_json" | jq '[.[] | select(.is_anonymous == true)] | length')
          echo "anonymous_users=$anonymous_count" >> $GITHUB_OUTPUT
          #
          # Count content creators
          creators_count=$(echo "$users_json" | jq '[.[] | select(.role == "content_creator")] | length')
          echo "content_creators=$creators_count" >> $GITHUB_OUTPUT
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
            const anonymousUsers = ${{ steps.get-users.outputs.users-json }}
              .filter(user => user.is_anonymous === true)
              .map(user => `- ${user.display_name} (${user.email})`)
              .join('\n');
            
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Found ${{ steps.analyze.outputs.anonymous_users }} anonymous users in Instruqt team`,
              body: `## Anonymous Users Detected\n\nThe following users are marked as anonymous:\n\n${anonymousUsers}\n\n**Action Required**: Review these accounts and determine if they should be converted to regular user accounts.`,
              labels: ['instruqt', 'user-audit', 'anonymous-users']
            });

      - name: Notify about content creators
        if: steps.analyze.outputs.content_creators > 10
        run: |
          echo "::warning::High number of content creators detected: ${{ steps.analyze.outputs.content_creators }}"
          echo "Consider reviewing content creator permissions for security purposes."
        shell: bash
```
