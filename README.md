# dvpe-helm

Collection of DVPE Helm Charts

Add the charts by executing the following commands:

```
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## How to release a new Helm Chart?

Each chart's `README.md` is generated via [helm-docs](https://github.com/norwoodj/helm-docs).

1. Update the documentation:  
   Edit (or create) the`README.md.gotmpl` file in the chart's folder and add your documentation like this:
   ```gotemplate
   {{/* Header and Version Badge */}}
   {{ template "chart.header" . }} 
   {{ template "chart.versionBadge" . }}

   {{ template "chart.description" . }}
   {{/* Here you can add your documentation text */}}

   {{/* Don't change the last lines from here on which generate a table from values.yaml */}}
   ## Chart Configuration Parameters
   The following table lists the configurable parameters of the chart and its default values.
   
   {{ template "chart.valuesSection" . }}
   ```
1. Run `helm-docs` inside the chart's folder to generate the `README.md` file
1. Increase version in `Chart.yaml`. Each merge to master is validated via GitHub Actions. If the version is not updated, the merge is not permitted.
   
