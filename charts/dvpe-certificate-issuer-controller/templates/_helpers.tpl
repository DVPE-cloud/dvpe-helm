{{- define "image.url" -}}
{{- printf "\"%s/%s:%s\"" .Values.issuercontroller.spec.image.repository .Values.issuercontroller.spec.image.name .Values.issuercontroller.spec.image.tag -}}
{{- end -}}

{{- define "container.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
