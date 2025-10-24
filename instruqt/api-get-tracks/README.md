# Instruqt Get Tracks Action

Use Instruqt API to get a list of tracks and their information.

This action interacts with the Instruqt GraphQL API to:

1. Get team information
2. List all tracks in the team
3. Get detailed information about each track
4. Save results to files and environment variables for further use in GitHub Actions
5. Print a summary of tracks found

## Deploying this action

### Inputs

See the `inputs` configured in the [action.yml](action.yml) file.

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `api-key` | The API key to authenticate with the Instruqt API | true | - |
| `team-workspace` | The team workspace slug to get tracks from | true | Auto-detected from API key |
| `verbose` | Determine if the action should run verbose tasks | false | `false` |

### Outputs

See the `outputs` configured in the [action.yml](action.yml) file.

| Output | Description |
|--------|-------------|
| `tracks-json` | A JSON string containing track information |

## Example Usage

Create a file named `.github/workflows/my-workflow.yml` with the following:

```yml
name: Get Instruqt Tracks

on:
  push:
    branches:
      - 'main'
    # ignore changes to .md files and the entire .github directory
    paths-ignore:
      - '**.md'
      - '.github/**'

jobs:
  get-tracks:
    runs-on: ubuntu-latest
    name: Get Instruqt Tracks
    steps:
      - name: Run the checkout action
        # Verified creator: https://github.com/marketplace/actions/checkout
        # GitHub Action for checking out a repo
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Instruqt tracks
        id: get-tracks
        uses: rwaight/actions/instruqt/api-get-tracks@main
        with:
          api-key: ${{ secrets.INSTRUQT_API_KEY }}
          team-workspace: 'my-team'
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Print track information
        run: |
          echo "Track information:"
          echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq '.'
```

### Advanced Example

```yml
name: Process Instruqt Tracks

on:
  schedule:
    - cron: '0 8 * * MON'  # Run every Monday at 8 AM
  workflow_dispatch:

jobs:
  process-tracks:
    runs-on: ubuntu-latest
    name: Process Instruqt Tracks
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Instruqt tracks
        id: get-tracks
        uses: rwaight/actions/instruqt/api-get-tracks@main
        with:
          api-key: ${{ secrets.INSTRUQT_API_KEY }}
          team-workspace: ${{ vars.INSTRUQT_TEAM_WORKSPACE }}
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Process track data
        run: |
          # Parse the JSON output and extract tracks by level
          echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq -r '
            group_by(.level) | 
            map({
              level: .[0].level,
              count: length,
              tracks: map(.title)
            }) | 
            .[] | 
            "\(.level): \(.count) tracks - \(.tracks | join(", "))"
          ' > tracks-by-level-report.txt
          #
          echo "Tracks by Level Report:"
          cat tracks-by-level-report.txt
          #
          # Extract published vs private tracks
          echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq -r '
            {
              published: [.[] | select(.published == true)],
              private: [.[] | select(.private == true)],
              maintenance: [.[] | select(.maintenance == true)]
            } |
            "Published: \(.published | length)\nPrivate: \(.private | length)\nMaintenance: \(.maintenance | length)"
          ' > tracks-status-report.txt
          #
          echo "Track Status Report:"
          cat tracks-status-report.txt
          #
          # Create CSV export of tracks
          echo "Title,Slug,Level,Published,Private,Challenges,Tags" > tracks-export.csv
          echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq -r '
            .[] |
            [.title, .slug, .level, .published, .private, .challenge_count, (.tags | join("; "))] |
            @csv
          ' >> tracks-export.csv
          #
          echo "Created CSV export with $(wc -l < tracks-export.csv) lines (including header)"
        shell: bash

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: tracks-report
          path: |
            team_tracks_list.txt
            team_tracks_details.json
            tracks-by-level-report.txt
            tracks-status-report.txt
            tracks-export.csv
            user-roles-report.txt
            user-domains-report.txt
            users-export.csv

      - name: Create summary
        run: |
          {
            echo "# Instruqt Tracks Report"
            echo ""
            echo "## Team Summary"
            total_tracks=$(echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq '. | length')
            echo "- **Total Tracks**: $total_tracks"
            echo ""
            echo "## Tracks by Level"
            echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq -r '
              group_by(.level) | 
              map("- **\(.[0].level)**: \(length) tracks") |
              .[]
            '
            echo ""
            echo "## Track Status"
            echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq -r '
              {
                published: [.[] | select(.published == true)] | length,
                private: [.[] | select(.private == true)] | length,
                maintenance: [.[] | select(.maintenance == true)] | length
              } |
              "- **Published**: \(.published) tracks\n- **Private**: \(.private) tracks\n- **In Maintenance**: \(.maintenance) tracks"
            '
          } >> $GITHUB_STEP_SUMMARY
        shell: bash
```

### Conditional Processing Example

```yml
name: Track Audit and Notifications

on:
  workflow_dispatch:
    inputs:
      check_maintenance:
        description: 'Check for tracks in maintenance mode'
        required: false
        default: 'false'
        type: boolean

jobs:
  audit-tracks:
    runs-on: ubuntu-latest
    name: Audit Instruqt Tracks
    steps:
      - name: Checkout repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Get Instruqt tracks
        id: get-tracks
        uses: rwaight/actions/instruqt/api-get-tracks@main
        with:
          api-key: ${{ secrets.INSTRUQT_API_KEY }}
          team-workspace: ${{ vars.INSTRUQT_TEAM_WORKSPACE }}
          verbose: ${{ runner.debug == '1' && 'true' || 'false' }}

      - name: Analyze track data
        id: analyze
        run: |
          tracks_json='${{ steps.get-tracks.outputs.tracks-json }}'
          #
          # Count tracks in maintenance
          maintenance_count=$(echo "$tracks_json" | jq '[.[] | select(.maintenance == true)] | length')
          echo "maintenance_tracks=$maintenance_count" >> $GITHUB_OUTPUT
          #
          # Count unpublished tracks
          unpublished_count=$(echo "$tracks_json" | jq '[.[] | select(.published == false)] | length')
          echo "unpublished_tracks=$unpublished_count" >> $GITHUB_OUTPUT
          #
          # Check for tracks without challenges
          no_challenges_count=$(echo "$tracks_json" | jq '[.[] | select(.challenge_count == 0)] | length')
          echo "tracks_no_challenges=$no_challenges_count" >> $GITHUB_OUTPUT
        shell: bash

      - name: Create issue for maintenance tracks
        if: steps.analyze.outputs.maintenance_tracks > 0
        uses: actions/github-script@v7
        with:
          script: |
            const maintenanceTracks = ${{ steps.get-tracks.outputs.tracks-json }}
              .filter(track => track.maintenance === true)
              .map(track => `- ${track.title} (${track.slug})`)
              .join('\n');
            
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Found ${{ steps.analyze.outputs.maintenance_tracks }} tracks in maintenance mode`,
              body: `## Tracks in Maintenance\n\nThe following tracks are in maintenance mode:\n\n${maintenanceTracks}\n\n**Action Required**: Review these tracks and update or remove maintenance status.`,
              labels: ['instruqt', 'track-audit', 'maintenance']
            });

      - name: Notify about unpublished tracks
        if: steps.analyze.outputs.unpublished_tracks > 5
        run: |
          echo "::warning::High number of unpublished tracks detected: ${{ steps.analyze.outputs.unpublished_tracks }}"
          echo "Consider reviewing and publishing or archiving these tracks."
        shell: bash
```
