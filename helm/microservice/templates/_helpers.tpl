{{/*
══════════════════════════════════════════════════════════
WHY THIS FILE?
_helpers.tpl defines reusable template snippets (like
functions). "fullname" computes the name used for the
Deployment, Service, and pod labels — either the Helm
release name, or nameOverride if set in a values-*.yaml.
══════════════════════════════════════════════════════════
*/}}

{{- define "microservice.fullname" -}}
{{- if .Values.nameOverride -}}
{{ .Values.nameOverride }}
{{- else -}}
{{ .Release.Name }}
{{- end -}}
{{- end -}}

{{- define "microservice.labels" -}}
app: {{ include "microservice.fullname" . }}
release: {{ .Release.Name }}
{{- end -}}
