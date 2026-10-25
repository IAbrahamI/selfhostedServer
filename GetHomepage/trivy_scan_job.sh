#!/bin/bash
TRIVY="aquasec/trivy@sha256:YOUR_DIGEST"
OUT=/opt/trivy/reports

mkdir -p "$OUT/images" && rm -f "$OUT"/images/*.json
IMAGES=$(docker ps --format '{{.Image}}' | sort -u)

docker run --rm --cpus 2 --tmpfs /root/.cache:size=4g \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v "$OUT/images":/reports \
  --entrypoint sh "$TRIVY" -c '
    for img in "$@"; do
      f=$(echo "$img" | tr "/:@" "___")
      trivy image --quiet --parallel 1 --scanners vuln --severity HIGH,CRITICAL \
        --format json -o "/reports/$f.json" "$img"
    done' sh $IMAGES

ls "$OUT"/images/*.json >/dev/null 2>&1 || exit 1

jq -s '{
  critical: ([.[].Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length),
  high:     ([.[].Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length),
  fixable:  ([.[].Results[]?.Vulnerabilities[]? | select((.FixedVersion // "") != "")] | length),
  images:   length,
  scanned:  (now | strflocaltime("%Y-%m-%d %H:%M"))
}' "$OUT"/images/*.json > "$OUT/summary.json"

{
  echo '<!doctype html><meta charset="utf-8"><title>Vulnerabilities</title>'
  echo '<body style="font-family:sans-serif;background:#1e293b;color:#e2e8f0;margin:20px">'
  jq -r '"<h1>Vulnerabilities</h1><p>Last scan: \(.scanned) | \(.critical) critical | \(.high) high | \(.fixable) fixable</p>"' "$OUT/summary.json"
  echo '<table cellpadding="6" style="border-collapse:collapse;width:100%">'
  echo '<tr align="left"><th>Image</th><th>Severity</th><th>CVE</th><th>Package</th><th>Installed</th><th>Fixed in</th></tr>'
  jq -rs '[.[] | .ArtifactName as $img | .Results[]?.Vulnerabilities[]? | . + {img: $img}]
    | sort_by(.Severity != "CRITICAL", .img)[]
    | "<tr style=\"border-top:1px solid #334155\"><td>\(.img|@html)</td>"
    + "<td style=\"color:\(if .Severity == "CRITICAL" then "#f87171" else "#fb923c" end)\">\(.Severity)</td>"
    + "<td><a style=\"color:#93c5fd\" href=\"\(.PrimaryURL // "#")\">\(.VulnerabilityID|@html)</a></td>"
    + "<td>\(.PkgName|@html)</td><td>\(.InstalledVersion|@html)</td><td>\(.FixedVersion // "-"|@html)</td></tr>"' "$OUT"/images/*.json
  echo '</table></body>'
} > "$OUT/index.html"
