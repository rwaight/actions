
:rocket: The PR labeler checks have passed!

The PR labeler enforces a single `type:` label on every pull request because we use commit types to drive our **software release process**—consistent typing on standard PRs keeps changelogs, versioning, and release automation accurate.

{{ if .auto_labeled -}}
Applied **`{{ .inferred_label }}`** automatically from consistent commit messages on this branch.
{{ end }}

- Label check result: {{ .label_check }}
- Label test name:    {{ .test_name }}
- Label test scope:   {{ .label_scope }}
{{ if .inferred_label -}}
- Inferred label:     {{ .inferred_label }}
{{ end -}}

<details><summary> comment source (click to expand) </summary>

This comment was created in **pull request {{ .event_number }}** using [create-or-update-comment][1].

[1]: https://github.com/rwaight/actions/tree/main/chatops/create-or-update-comment#github-create-or-update-comment-action

</details>
