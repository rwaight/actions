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
| `tracks-json` | A JSON string containing track information (only available if under 1MB size limit) |
| `tracks-json-available` | Whether the tracks JSON is available in outputs (true/false) |
| `total-tracks` | Total number of tracks found |
| `total-published` | Total number of published tracks |
| `total-private` | Total number of private tracks |
| `total-maintenance` | Total number of tracks in maintenance mode |

> **Note**: If the tracks JSON exceeds GitHub's 1MB output size limit, it will not be available in the `tracks-json` output. Check `tracks-json-available` to determine availability, and use the `team_tracks_details.json` artifact file instead.

GitHub Actions has limits for individual step outputs as well as limits for the total size of all outputs in a workflow run (see [Usage limits documentation](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration#usage-limits)). This action intelligently handles these constraints by checking the JSON data size before attempting to export it as an output. When the data exceeds the limit, the action sets `tracks-json-available` to `false` and directs users to the artifact files instead, ensuring reliable operation regardless of dataset size.

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

      - name: Print track counts
        run: |
          echo "Total tracks: ${{ steps.get-tracks.outputs.total-tracks }}"
          echo "Published: ${{ steps.get-tracks.outputs.total-published }}"
          echo "Private: ${{ steps.get-tracks.outputs.total-private }}"
          echo "In Maintenance: ${{ steps.get-tracks.outputs.total-maintenance }}"

      - name: Print track information (if available)
        if: steps.get-tracks.outputs.tracks-json-available == 'true'
        run: |
          echo "Track information:"
          echo '${{ steps.get-tracks.outputs.tracks-json }}' | jq '.'

      - name: Use artifact file (if JSON too large)
        if: steps.get-tracks.outputs.tracks-json-available == 'false'
        run: |
          echo "Tracks JSON too large for output, using artifact file instead"
          cat team_tracks_details.json | jq '.'
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

      - name: Display track summary
        run: |
          echo "### Track Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "- **Total Tracks**: ${{ steps.get-tracks.outputs.total-tracks }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Published**: ${{ steps.get-tracks.outputs.total-published }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Private**: ${{ steps.get-tracks.outputs.total-private }}" >> $GITHUB_STEP_SUMMARY
          echo "- **In Maintenance**: ${{ steps.get-tracks.outputs.total-maintenance }}" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "- **JSON Output Available**: ${{ steps.get-tracks.outputs.tracks-json-available }}" >> $GITHUB_STEP_SUMMARY

      - name: Process track data from output
        if: steps.get-tracks.outputs.tracks-json-available == 'true'
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

      - name: Process track data from file
        if: steps.get-tracks.outputs.tracks-json-available == 'false'
        run: |
          # Use the JSON file when output is too large
          cat team_tracks_details.json | jq -r '
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
          echo "Tracks by Level Report (from file):"
          cat tracks-by-level-report.txt

      - name: Create detailed reports
        run: |
          # Determine source of track data
          if [ "${{ steps.get-tracks.outputs.tracks-json-available }}" == "true" ]; then
            TRACKS_DATA='${{ steps.get-tracks.outputs.tracks-json }}'
          else
            TRACKS_DATA=$(cat team_tracks_details.json)
          fi
          
          # Extract published vs private tracks
          echo "$TRACKS_DATA" | jq -r '
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
          echo "$TRACKS_DATA" | jq -r '
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

      - name: Create summary
        run: |
          {
            echo "# Instruqt Tracks Report"
            echo ""
            echo "## Team Summary"
            echo "- **Total Tracks**: ${{ steps.get-tracks.outputs.total-tracks }}"
            echo "- **Published**: ${{ steps.get-tracks.outputs.total-published }}"
            echo "- **Private**: ${{ steps.get-tracks.outputs.total-private }}"
            echo "- **In Maintenance**: ${{ steps.get-tracks.outputs.total-maintenance }}"
            echo ""
            
            # Determine source and add appropriate note
            if [ "${{ steps.get-tracks.outputs.tracks-json-available }}" == "true" ]; then
              TRACKS_DATA='${{ steps.get-tracks.outputs.tracks-json }}'
              echo "_Data source: Action output_"
            else
              TRACKS_DATA=$(cat team_tracks_details.json)
              echo "_Data source: Artifact file (output too large)_"
            fi
            
            echo ""
            echo "## Tracks by Level"
            echo "$TRACKS_DATA" | jq -r '
              group_by(.level) | 
              map("- **\(.[0].level)**: \(length) tracks") |
              .[]
            '
            echo ""
            echo "## Track Status Breakdown"
            echo "$TRACKS_DATA" | jq -r '
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

      - name: Check maintenance tracks using output count
        if: steps.get-tracks.outputs.total-maintenance > 0
        run: |
          echo "::warning::Found ${{ steps.get-tracks.outputs.total-maintenance }} tracks in maintenance mode"

      - name: Analyze track data
        id: analyze
        run: |
          # Determine source of track data
          if [ "${{ steps.get-tracks.outputs.tracks-json-available }}" == "true" ]; then
            tracks_json='${{ steps.get-tracks.outputs.tracks-json }}'
          else
            tracks_json=$(cat team_tracks_details.json)
          fi
          
          # Count unpublished tracks
          unpublished_count=$(echo "$tracks_json" | jq '[.[] | select(.published == false)] | length')
          echo "unpublished_tracks=$unpublished_count" >> $GITHUB_OUTPUT
          #
          # Check for tracks without challenges
          no_challenges_count=$(echo "$tracks_json" | jq '[.[] | select(.challenge_count == 0)] | length')
          echo "tracks_no_challenges=$no_challenges_count" >> $GITHUB_OUTPUT
        shell: bash

      - name: Create issue for maintenance tracks
        if: steps.get-tracks.outputs.total-maintenance > 0
        uses: actions/github-script@v7
        with:
          script: |
            let maintenanceTracks;
            
            if ('${{ steps.get-tracks.outputs.tracks-json-available }}' === 'true') {
              const tracksData = ${{ steps.get-tracks.outputs.tracks-json }};
              maintenanceTracks = tracksData
                .filter(track => track.maintenance === true)
                .map(track => `- ${track.title} (${track.slug})`)
                .join('\n');
            } else {
              const fs = require('fs');
              const tracksData = JSON.parse(fs.readFileSync('team_tracks_details.json', 'utf8'));
              maintenanceTracks = tracksData
                .filter(track => track.maintenance === true)
                .map(track => `- ${track.title} (${track.slug})`)
                .join('\n');
            }
            
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Found ${{ steps.get-tracks.outputs.total-maintenance }} tracks in maintenance mode`,
              body: `## Tracks in Maintenance\n\nThe following tracks are in maintenance mode:\n\n${maintenanceTracks}\n\n**Action Required**: Review these tracks and update or remove maintenance status.`,
              labels: ['instruqt', 'track-audit', 'maintenance']
            });

      - name: Notify about unpublished tracks
        if: steps.analyze.outputs.unpublished_tracks > 5
        run: |
          echo "::warning::High number of unpublished tracks detected: ${{ steps.analyze.outputs.unpublished_tracks }}"
          echo "Consider reviewing and publishing or archiving these tracks."
        shell: bash

      - name: Alert on tracks without challenges
        if: steps.analyze.outputs.tracks_no_challenges > 0
        run: |
          echo "::warning::Found ${{ steps.analyze.outputs.tracks_no_challenges }} tracks with no challenges"
          echo "These tracks may be incomplete or require attention."
        shell: bash
```

## Output Size Considerations

The action includes smart handling for large datasets:

- **JSON Output**: Available via `tracks-json` output only if data is under 1MB
- **Availability Flag**: Check `tracks-json-available` to determine if JSON is in outputs
- **Artifact Files**: Always generated regardless of size:
  - `team_tracks_list.txt` - Human-readable track list
  - `team_tracks_details.json` - Complete JSON data
- **Count Outputs**: Always available regardless of dataset size:
  - `total-tracks`
  - `total-published`
  - `total-private`
  - `total-maintenance`

When processing large track datasets, use the conditional logic shown in the advanced examples to automatically fall back to artifact files when needed.
