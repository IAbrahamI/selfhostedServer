#!/bin/bash
TRIVY="aquasec/trivy@sha256:YOUR_DIGEST"
OUT=/opt/trivy/reports

mkdir -p "$OUT/images" && rm -f "$OUT"/images/*.json
IMAGES=$(docker ps --format '{{.Image}}' | sort -u)

docker run --rm --tmpfs /root/.cache:size=2g \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v "$OUT/images":/reports \
  --entrypoint sh "$TRIVY" -c '
    for img in "$@"; do
      f=$(echo "$img" | tr "/:@" "___")
      trivy image --quiet --scanners vuln --severity HIGH,CRITICAL \
        --format json -o "/reports/$f.json" "$img"
    done' sh $IMAGES

jq -s '{
  critical: ([.[].Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length),
  high:     ([.[].Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length),
  fixable:  ([.[].Results[]?.Vulnerabilities[]? | select((.FixedVersion // "") != "")] | length),
  images:   length,
  scanned:  (now | strflocaltime("%Y-%m-%d %H:%M"))
}' "$OUT"/images/*.json > "$OUT/summary.json"
