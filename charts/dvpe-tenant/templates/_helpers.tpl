# Takes a https repository url from GitHub and parses out "<org-name>-<repo-name>"
# Example "https://github.com/jeremy/fragrance.git" -> "jeremy-fragrance"
{{- define "normalizeRepoPath" }}
  {{- mustRegexReplaceAll "https://(.*)/(.*)/(.*).git" . "${2}-${3}" | lower }}
{{- end }}
