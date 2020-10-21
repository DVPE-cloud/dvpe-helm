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
{{- printf "%s-%s-svc-%s" .Release.Namespace $serviceName .Values.service.spec.ports.http.port -}}
{{- end -}}


