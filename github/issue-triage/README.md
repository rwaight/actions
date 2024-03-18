# Issue Triage Action

The current version in this repo is based off of [**issue-triage-action** v1.0.0](https://github.com/krizzu/issue-triage-action/releases/tag/v1.0.0)
- **Note**: You must use the (classic) personal access tokens when configuring the `ghToken`
- This action is from https://github.com/krizzu/issue-triage-action.

The [`krizzu/issue-triage-action`](https://github.com/krizzu/issue-triage-action/) has a MIT License:
> A short and simple permissive license with conditions only requiring preservation of copyright and license notices. Licensed works, modifications, and larger works may be distributed under different terms and without source code.

### Features

- find, comment and label the issue if it exceeds the selected `staleAfter` day limit 
- close the issue down after the `closeAfter` day limit is reached
- customize the comment posted when the issue is stale or closed
- select label to be set for stale issues


## Deploying this action

### Inputs

- `ghToken` **Required**, GitHub token
- `staleAfter` *int*, number of days to consider an issue to be stale, __default__: `30`
- `closeAfter` *int*, number of days after the issue should be closed (0 days means off, must be higher than `staleAfter`), __default__: `0`
- `staleLabel` *string*, a label to be set to the stale issue, __default__: `STALE`
- `staleComment` *string*, a comment placed when marking issue as stale. See a [guide on how to style this message](#template-comment).
- `closeComment` *string*, a comment placed when closing issue. See a [guide on how to style this message](#template-comment).
- `showLogs` *bool*. Show logs with info like total number of issues found, stale issues, closed etc. __default__: `true`

### Example usage

In the repo `.github/workflows/` directory, create a file named `issue-triage.yml` with the following contents:
```yaml
name: Issue triage and cleanup
on:
  schedule:
    #- cron: '0 23 14 * *'   # At 2300 UTC on the 14th day of each month
    - cron: '15 13 * * 2,4'  # At 1315 UTC every Tuesday and Thursday
    #- cron: '15 9 * * 1-5'  # At 0915 UTC every Monday thru Friday
    #- cron: '15 9 * * *'    # At 0915 UTC every day
    #- cron: '* */12 * * *'  # Every 12 hours
jobs:
  triage_issues:
    name: Run issue triage
    runs-on: ubuntu-22.04
    steps:
      - name: Find old issues and mark them stale
        #uses: rwaight/actions/github/issue-triage@main    # can use main or specific version
        #uses: rwaight/actions/github/issue-triage@v1.1.0  # can use main or specific version
        uses: rwaight/actions/github/issue-triage@v1
        with:
          ghToken: ${{ secrets.MY_PROJECTS_TOKEN }}
          staleAfter: 60
          # do not set 'staleAfter' to anything less than 30 in production
          closeAfter: 180
          staleLabel: "STALE 📺"
          staleComment: "This issue is %DAYS_OLD% days old, marking as stale! cc: @%AUTHOR%"
          # you can remove or comment out 'staleComment' to use the default 'staleComment'
          closeComment: "Issue last updated %DAYS_OLD% days ago! Closing down!"
          # you can remove or comment out 'closeComment' to use the default 'closeComment'
          showLogs: true
```


### Template comment
 
 The comment is a template string with placeholders to use:

- `%AUTHOR%` - Issue creator
- `%DAYS_OLD%` - How long (in days) the issue was last updated

Example:

```yaml
with:
  closeComment: "This issue is %DAYS_OLD% old, closing down! Notifying author: @%AUTHOR%"
```
