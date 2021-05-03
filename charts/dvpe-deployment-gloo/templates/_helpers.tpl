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
{{- define "deployment.spec.serviceAccountName" -}}
  {{- if .Values.deployment.spec.serviceAccountName -}}
    {{- .Values.deployment.spec.serviceAccountName -}}
  {{- else -}}
    {{- printf "%s-sa" .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Check the go primitive kind and set the domain correctly to avoid breaking changes  */}}
{{- define "gloo.virtualservice.spec.virtualHost.domains" -}}
  {{- if kindIs "string" .Values.gloo.virtualservice.spec.virtualHost.domains -}}
    {{- .Values.gloo.virtualservice.spec.virtualHost.domains}}
  {{- else -}}
    {{- range .Values.gloo.virtualservice.spec.virtualHost.domains }}
    - {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Expand the oauth2.oidcAuthorizationCode.appUrl with the protocol and the domain */}}
{{- define "oauth2.oidcAuthorizationCode.appUrl" -}}
  {{- if kindIs "string" .Values.gloo.virtualservice.spec.virtualHost.domains -}}
    {{- printf "https://%s" .Values.gloo.virtualservice.spec.virtualHost.domains -}}
{{/* Prevents from failing if domain value is empty  */}}
  {{- else if .Values.gloo.virtualservice.spec.virtualHost.domains }}
    {{- index .Values.gloo.virtualservice.spec.virtualHost.domains 0 | printf "https://%s" -}}
  {{- else -}}
      {{- .Values.gloo.virtualservice.spec.virtualHost.domains | printf "https://%s" -}}
  {{- end }}
{{- end -}}
