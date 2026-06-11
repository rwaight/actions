
{{ if .is_new }}<!-- infra-updater-pr-log -->
**Infra-updater PR log**

{{ end }}{{ if eq .outcome "success" }}✅ Manifest validated{{ else }}❌ Manifest validation failed{{ end }} — [run #{{ .run_number }}]({{ .run_url }}) `{{ .timestamp }}`
