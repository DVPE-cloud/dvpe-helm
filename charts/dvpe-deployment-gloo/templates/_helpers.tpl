{{/* vim: set filetype=mustache: */}}

{{/* Expand the name of the chart. */}}
{{- define "service.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand Nexus image url. */}}
{{- define "image.url" -}}
{{- printf "\"%s/%s:%s\"" .Values.deployment.spec.image.repository .Values.deployment.spec.image.name .Values.deployment.spec.image.tag -}}
{{- end -}}

{{/* Expand Gloo upstream.name */}}
{{- define "upstream.name" -}}
{{- $serviceName := include "service.name" . -}}
{{/* TODO: Need to be changed to "%s-%s-svc-%s". Can be done after gloo isn't creating upstreams automatically */}}
{{- printf "%s-%s-%s" .Release.Namespace $serviceName .Values.service.spec.ports.https.port -}}
{{- end -}}

{{/* Expand serviceAccountName */}}
{{- define "serviceAccountName" -}}
{{- if .Values.deployment.spec.serviceAccountName -}}
{{- .Values.deployment.spec.serviceAccountName -}}
{{- else -}}
{{- printf "%s-sa" .Release.Namespace -}}
{{- end -}}
{{- end -}}

