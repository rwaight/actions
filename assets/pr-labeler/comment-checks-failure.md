
:disappointed: The PR labeler checks have failed!

The PR labeler enforces a single `type:` label on every pull request because we use commit types to drive our **software release process**—consistent typing on standard PRs keeps changelogs, versioning, and release automation accurate.

{{ with .failure_reason -}}
{{ if eq . "mixed-commits-need-label" -}}
This pull request has **mixed commit types** (`{{ $.commit_types_found }}`) and no `type:` label. Add the most appropriate `type:` label for the overall change (for example, `type:feat` or `type:fix`).
{{ else if eq . "label-mismatch" -}}
The `type:` label on this pull request does not match the commit messages. All commits use a single type (`{{ $.commit_types_found }}`), which maps to `{{ $.inferred_label }}`. Update the label or rewrite commits so they agree.
{{ else if eq . "multiple-type-labels" -}}
This pull request has more than one `type:` label. Only one `type:` label is allowed.
{{ else if eq . "missing-label-in-repo" -}}
Commits indicate `{{ $.inferred_label }}`, but that label does not exist in this repository. Ask a maintainer to sync labels or use a commit type that has a matching `type:` label.
{{ else if eq . "no-committable-commits" -}}
No evaluable commits were found on this branch (all commits were skipped as merge commits, WIP, dependabot, or non-conventional). Add at least one conventional commit message, or set a `type:` label manually. Commit message format is enforced separately by the commitlint workflow.
{{ else -}}
This pull request is missing the proper `{{ $.label_scope }}:` label; only one `{{ $.label_scope }}:` label is allowed.
{{ end -}}
{{ else -}}
This pull request is missing the proper `{{ .label_scope }}:` label; only one `{{ .label_scope }}:` label is allowed.
{{ end }}

- Label check result: {{ .label_check }}
- Label test name:    {{ .test_name }}
- Label test scope:   {{ .label_scope }}
- Label step outcome: {{ .step_outcome }}
{{ if .commit_types_found -}}
- Commit types found: {{ .commit_types_found }}
{{ end -}}
{{ if .inferred_label -}}
- Inferred label:     {{ .inferred_label }}
{{ end -}}

<details><summary> comment source (click to expand) </summary>

This comment was created in **pull request {{ .event_number }}** using [create-or-update-comment][1].

[1]: https://github.com/rwaight/actions/tree/main/chatops/create-or-update-comment#github-create-or-update-comment-action

</details>
