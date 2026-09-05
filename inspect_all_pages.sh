#!/usr/bin/env bash
set -uo pipefail

owner="standardgalactic"

repos_file="websites.jsonl"
summary_file="website_summary.json"
files_file="deployed_html_files.tsv"
urls_file="deployed_html_urls.txt"
errors_file="deployed_html_errors.log"

: > "$repos_file"
: > "$files_file"
: > "$urls_file"
: > "$errors_file"

echo "Fetching repositories for $owner..." >&2

if ! gh api --paginate \
  -H "Accept: application/vnd.github+json" \
  "/users/$owner/repos?per_page=100&sort=full_name" |
  jq -c '.[]' > "$repos_file"
then
  echo "Failed to retrieve repositories." >&2
  exit 1
fi

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
    nonfork_github_pages:
      map(select(
        .fork == false and
        .has_pages == true
      ))
      | length
  }
' "$repos_file" |
tee "$summary_file"

page_count=$(jq -s 'map(select(.has_pages == true)) | length' "$repos_file")
current=0

jq -r '
  select(.has_pages == true) |
  [.full_name, .default_branch] |
  @tsv
' "$repos_file" |
while IFS=$'\t' read -r repo default_branch; do
  current=$((current + 1))
  echo "[$current/$page_count] Inspecting $repo..." >&2

  pages=""

  if pages=$(gh api "repos/$repo/pages" 2>>"$errors_file"); then
    branch=$(jq -r '.source.branch // empty' <<<"$pages")
    source_path=$(jq -r '.source.path // "/"' <<<"$pages")
    build_type=$(jq -r '.build_type // "legacy"' <<<"$pages")
  else
    branch=""
    source_path="/"
    build_type="unknown"
    printf '%s\t%s\n' \
      "$repo" \
      "Could not read Pages configuration; using default branch" \
      >>"$errors_file"
  fi

  # Workflow-based Pages deployments may not report a source branch.
  # In that case, inspect the default branch from the repository metadata.
  if [[ -z "$branch" ]]; then
    branch="$default_branch"
    source_path="/"
    printf '%s\t%s\n' \
      "$repo" \
      "No Pages source branch; inspecting default branch $branch" \
      >>"$errors_file"
  fi

  if [[ -z "$branch" ]]; then
    printf '%s\t%s\n' \
      "$repo" \
      "No usable branch found" \
      >>"$errors_file"
    continue
  fi

  encoded_branch=$(jq -rn \
    --arg value "$branch" \
    '$value | @uri')

  if ! commit=$(gh api \
    "repos/$repo/commits/$encoded_branch" \
    2>>"$errors_file")
  then
    printf '%s\t%s\n' \
      "$repo" \
      "Could not resolve branch $branch" \
      >>"$errors_file"
    continue
  fi

  tree_sha=$(jq -r '.commit.tree.sha // empty' <<<"$commit")

  if [[ -z "$tree_sha" ]]; then
    printf '%s\t%s\n' \
      "$repo" \
      "No tree SHA returned for $branch" \
      >>"$errors_file"
    continue
  fi

  if ! tree=$(gh api \
    -X GET \
    "repos/$repo/git/trees/$tree_sha" \
    -f recursive=1 \
    2>>"$errors_file")
  then
    printf '%s\t%s\n' \
      "$repo" \
      "Could not retrieve tree $tree_sha" \
      >>"$errors_file"
    continue
  fi

  if [[ $(jq -r '.truncated // false' <<<"$tree") == "true" ]]; then
    printf '%s\t%s\n' \
      "$repo" \
      "GitHub truncated the recursive tree; results may be incomplete" \
      >>"$errors_file"
  fi

  jq -r \
    --arg repo "$repo" \
    --arg branch "$branch" \
    --arg root "$source_path" \
    --arg build "$build_type" '
      def cleanroot:
        $root
        | sub("^/"; "")
        | sub("/$"; "");

      def relative($path; $root):
        if $root == "" then
          $path
        elif $path == $root then
          ""
        elif ($path | startswith($root + "/")) then
          $path[(($root | length) + 1):]
        else
          null
        end;

      cleanroot as $root
      |
      .tree[]
      | select(.type == "blob")
      | .path as $path
      | relative($path; $root) as $relative
      | select($relative != null)
      | select($relative | test("\\.html?$"; "i"))
      |
      [
        $repo,
        $branch,
        ($root | if . == "" then "/" else "/" + . end),
        $path,
        $relative,
        $build
      ]
      | @tsv
    ' <<<"$tree" >>"$files_file"

done

sort -u -o "$files_file" "$files_file"

awk -F '\t' -v owner="$owner" '
{
  repo=$1
  relative=$5

  sub("^" owner "/", "", repo)

  if (repo == owner ".github.io")
    base="https://" owner ".github.io/"
  else
    base="https://" owner ".github.io/" repo "/"

  url=base relative

  # Convert index.html paths to their usual public directory URLs.
  sub(/index\.html?$/, "", url)

  print url
}
' "$files_file" |
sort -u > "$urls_file"

echo >&2
echo "Finished." >&2
echo "HTML files found: $(wc -l < "$files_file")" >&2
echo "Unique live URLs: $(wc -l < "$urls_file")" >&2
echo "File inventory: $files_file" >&2
echo "URL inventory:  $urls_file" >&2
echo "Warnings:       $errors_file" >&2

echo >&2
echo "Remaining GitHub API allowance:" >&2
gh api rate_limit \
  --jq '.resources.core |
        "Used: \(.used), remaining: \(.remaining), resets: \(.reset)"' \
  2>>"$errors_file" || true
