{{/* vim: set filetype=mustache: */}}

{{/* Expand the name of the chart. */}}
{{- define "service.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand Nexus image url. */}}
{{- define "image.url" -}}
{{- printf "\"%s/%s:%s\"" .Values.deployment.spec.image.repository .Values.deployment.spec.image.name .Values.deployment.spec.image.tag -}}
{{- end -}}

{{/*TODO: Remove if ticket is solved https://github.com/solo-io/gloo/issues/4691 */}}
{{/* Expand Gloo upstream.name */}}
{{- define "upstream.name" -}}
{{- $serviceName := include "service.name" . -}}
{{- $servicePort := or .Values.service.spec.ports.https.port .Values.service.spec.ports.http.port -}}
{{- printf "%s-%s-%s" .Release.Namespace $serviceName $servicePort -}}
{{- end -}}

{{/* Expand serviceAccountName */}}
{{- define "deployment.spec.serviceAccountName" -}}
  {{- if .Values.deployment.spec.serviceAccountName -}}
    {{- .Values.deployment.spec.serviceAccountName -}}
  {{- else -}}
    {{- printf "%s-sa" .Release.Namespace -}}
  {{- end -}}
{{- end -}}


{{/*TODO: Check functionality and remove with next major version upgrade */}}
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


{{/*TODO: Check if domain may be string or list. remove if not needed*/}}
{{/* If domains are defined as string it converts domains to single element list, if domians is a list this list is returned  */}}
{{- define "gloo.virtualservice.spec.virtualHost.domains.as.list" -}}
  {{- if kindIs "string" .Values.gloo.virtualservice.spec.virtualHost.domains -}}
   - {{ .Values.gloo.virtualservice.spec.virtualHost.domains}}
  {{- else -}}
    {{- range .Values.gloo.virtualservice.spec.virtualHost.domains }}
      - {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*TODO: Check if domain may be string or list. remove if not needed*/}}
{{/* If domains are defined as string string value is returned, if domians is a list the first value from the list ist returned */}}
{{- define "gloo.virtualservice.spec.virtualHost.domains.first" -}}
  {{- if kindIs "string" .Values.gloo.virtualservice.spec.virtualHost.domains -}}
   {{ .Values.gloo.virtualservice.spec.virtualHost.domains}}
  {{- else -}}
    {{index .Values.gloo.virtualservice.spec.virtualHost.domains 0}}
  {{- end }}
{{- end -}}

{{/*TODO: Check functionality and simplify with next major version upgrade */}}
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
