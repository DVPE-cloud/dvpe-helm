{{- define "image.url" -}}
{{- printf "\"%s/%s:%s\"" .Values.issuercontroller.spec.image.repository .Values.issuercontroller.spec.image.name .Values.issuercontroller.spec.image.tag -}}
{{- end -}}