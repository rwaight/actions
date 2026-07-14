{{ if .is_new }}<!-- infra-updater-pr-log -->
**Infra-updater PR log**

{{ end }}⏸️ Auto-merge suppressed (breaking-change detection{{ if .breaking_change_ids }}: {{ .breaking_change_ids }}{{ end }}) — [run #{{ .run_number }}]({{ .run_url }}) `{{ .timestamp }}`
Manual merge required after review.
