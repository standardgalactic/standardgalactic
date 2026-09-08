#!/usr/bin/env bash
set -euo pipefail

owner="standardgalactic"
out="websites.jsonl"
inventory="website_inventory.tsv"

echo "Fetching repositories for $owner..." >&2

gh api --paginate \
  -H "Accept: application/vnd.github+json" \
  "/users/$owner/repos?per_page=100&sort=full_name" |
jq -c '.[]' > "$out"

jq -s '
  def external_homepage:
    (.homepage // "") as $url |
    ($url | test("^https?://")) and
    ($url | contains("github.com") | not);

  {
    total_repositories: length,

    github_pages_enabled:
      map(select(.has_pages == true)) | length,

    external_homepage_listed:
      map(select(external_homepage)) | length,

    pages_or_external_deployment:
      map(select(.has_pages == true or external_homepage))
      | unique_by(.full_name)
      | length,

    primarily_html:
      map(select(.language == "HTML")) | length,

    nonfork_pages_or_deployments:
      map(select(
        .fork == false and
        (.has_pages == true or external_homepage)
      ))
      | unique_by(.full_name)
      | length
  }
' "$out"

jq -r --arg owner "$owner" '
  def external_homepage:
    (.homepage // "") as $url |
    ($url | test("^https?://")) and
    ($url | contains("github.com") | not);

  select(.has_pages == true or external_homepage) |

  [
    .name,
    (if .has_pages then "GitHub Pages" else "external" end),
    (
      if (.homepage // "") != ""
      then .homepage
      else "https://\($owner).github.io/\(.name)/"
      end
    ),
    (if .fork then "fork" else "original" end)
  ]
  | @tsv
' "$out" |
sort > "$inventory"

echo "Inventory written to $inventory" >&2
