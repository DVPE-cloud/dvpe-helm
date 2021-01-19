{{/* vim: set filetype=mustache: */}}

{{/* Port of the Upstream. */}}
{{- define "upstream.port" -}}
{{- if contains (index . "Values" "argo-cd" "server" "extraArgs") "--insecure" -}}
{{- "80" -}}
{{- else -}}
{{- "443" -}}
{{- end -}}
{{- end -}}

{{/* Name of the Service. */}}
{{- define "servicename" -}}
{{- "argocd-server" }}
{{- end -}}

{{/* Name of the Upstream. */}}
{{- define "upstream.name" -}}
{{- $port := include "upstream.port" . -}}
{{- $serviceName := include "servicename" . -}}
{{- printf "%s-%s-%s" .Release.Namespace $serviceName $port -}}
{{- end -}}



{{/* Name of the Virtual Service. */}}
{{- define "virtualservice.name" -}}
{{- $serviceName := include "servicename" . -}}
{{- printf "%s-%s" .Release.Namespace $serviceName -}}
{{- end -}}
