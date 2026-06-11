
{{ if .is_new }}<!-- infra-updater-pr-log -->
**Infra-updater PR log**

{{ end }}{{ if eq .outcome "success" }}🔀 Auto-merge triggered{{ else }}⚠️ Auto-merge step failed{{ end }} — [run #{{ .run_number }}]({{ .run_url }}) `{{ .timestamp }}`
