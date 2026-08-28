#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: survey-repository.sh [OPTIONS] [REPOSITORY]

Extract missing PDF text, inventory a repository, summarize each top-level
project with Ollama, and synthesize a repository overview. REPOSITORY defaults
to the current directory.

Options:
  --model NAME          Ollama model (default: granite4.1:8b)
  --output DIR          Report directory (default: .repo-overview)
  --max-chars N         Maximum context characters per project (default: 60000)
  --file-chars N        Maximum characters taken from one file (default: 12000)
  --extract-only        Only create missing sibling .txt files from PDFs
  --inventory-only      Extract PDF text and create deterministic inventory
  --summaries-only      Skip PDF extraction; build inventory and summaries
  --refresh-pdf-text    Replace sibling .txt files older than their PDFs
  --force               Regenerate summaries even when inputs appear unchanged
  --quiet               Save Ollama responses without streaming them to screen
  --no-root-summary     Do not summarize loose files in the repository root
  -h, --help            Show this help

Generated files:
  .repo-overview/INVENTORY.md
  .repo-overview/projects/*.md
  .repo-overview/REPOSITORY-OVERVIEW.md
  .repo-overview/run.log
EOF
}

model=granite4.1:8b
output_arg=.repo-overview
max_chars=60000
file_chars=12000
mode=all
refresh_pdf_text=false
force=false
stream_output=true
root_summary=true
repository=.
repository_set=false

while (($#)); do
  case $1 in
    --model) model=${2:?--model requires a value}; shift ;;
    --output) output_arg=${2:?--output requires a value}; shift ;;
    --max-chars) max_chars=${2:?--max-chars requires a value}; shift ;;
    --file-chars) file_chars=${2:?--file-chars requires a value}; shift ;;
    --extract-only) mode=extract ;;
    --inventory-only) mode=inventory ;;
    --summaries-only) mode=summaries ;;
    --refresh-pdf-text) refresh_pdf_text=true ;;
    --force) force=true ;;
    --quiet) stream_output=false ;;
    --no-root-summary) root_summary=false ;;
    -h|--help) usage; exit 0 ;;
    --*) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
    *)
      $repository_set && { printf 'Only one repository may be supplied.\n' >&2; exit 2; }
      repository=$1
      repository_set=true
      ;;
  esac
  shift
done

[[ $max_chars =~ ^[1-9][0-9]*$ ]] || { printf '%s\n' '--max-chars must be a positive integer.' >&2; exit 2; }
[[ $file_chars =~ ^[1-9][0-9]*$ ]] || { printf '%s\n' '--file-chars must be a positive integer.' >&2; exit 2; }

repository=$(realpath -- "$repository")
[[ -d $repository ]] || { printf 'Not a directory: %s\n' "$repository" >&2; exit 1; }

if [[ $output_arg = /* ]]; then
  output=$output_arg
else
  output=$repository/$output_arg
fi
mkdir -p -- "$output/projects" "$output/state"
log=$output/run.log
: > "$log"

say() { printf '%s\n' "$*" | tee -a "$log"; }
die() { printf 'Error: %s\n' "$*" | tee -a "$log" >&2; exit 1; }
command -v find >/dev/null || die 'find is required.'
command -v realpath >/dev/null || die 'realpath is required.'

output_rel=
if [[ $output == "$repository"/* ]]; then
  output_rel=${output#"$repository"/}
fi

find_repo() {
  local -a args=("$repository")
  args+=( \( -type d \( -name .git -o -name .cleanup-quarantine -o -name node_modules -o -name __pycache__ \) \) -prune )
  if [[ -n $output_rel ]]; then
    args+=( -o -path "$output" -prune )
  fi
  args+=( -o "$@" )
  find "${args[@]}"
}

extract_pdfs() {
  command -v pdftotext >/dev/null || die 'pdftotext is required for PDF extraction (package: poppler-utils).'
  local pdf text made=0 skipped=0 failed=0
  while IFS= read -r -d '' pdf; do
    text=${pdf%.*}.txt
    if [[ -e $text ]] && { ! $refresh_pdf_text || [[ $text -nt $pdf ]]; }; then
      ((++skipped))
      continue
    fi
    say "Extracting: ${pdf#"$repository"/}"
    if pdftotext -layout -nopgbrk -- "$pdf" "$text" 2>>"$log"; then
      ((++made))
    else
      rm -f -- "$text"
      ((++failed))
    fi
  done < <(find_repo -type f -iname '*.pdf' -print0)
  say "PDF extraction: $made created, $skipped already present, $failed failed."
}

write_inventory() {
  local inventory=$output/INVENTORY.md
  local files dirs bytes pdfs texts tex markdown images audio video code
  files=$(find_repo -type f -printf '.' | wc -c)
  dirs=$(find_repo -type d -printf '.' | wc -c)
  bytes=$(find_repo -type f -printf '%s\n' | awk '{s+=$1} END {printf "%.0f", s+0}')
  pdfs=$(find_repo -type f -iname '*.pdf' -printf '.' | wc -c)
  texts=$(find_repo -type f -iname '*.txt' -printf '.' | wc -c)
  tex=$(find_repo -type f -iname '*.tex' -printf '.' | wc -c)
  markdown=$(find_repo -type f \( -iname '*.md' -o -iname '*.markdown' \) -printf '.' | wc -c)
  images=$(find_repo -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' \) -printf '.' | wc -c)
  audio=$(find_repo -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' -o -iname '*.m4a' \) -printf '.' | wc -c)
  video=$(find_repo -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \) -printf '.' | wc -c)
  code=$(find_repo -type f \( -iname '*.py' -o -iname '*.sh' -o -iname '*.rs' -o -iname '*.js' -o -iname '*.ts' -o -iname '*.html' -o -iname '*.css' -o -iname '*.lean' \) -printf '.' | wc -c)

  {
    printf '# Repository Inventory\n\n'
    printf 'Generated: %s  \nRepository: `%s`\n\n' "$(date -u +'%Y-%m-%d %H:%M UTC')" "$repository"
    printf '## Totals\n\n'
    printf '| Measure | Count |\n|---|---:|\n'
    printf '| Directories | %s |\n| Files | %s |\n| Bytes | %s |\n' "$dirs" "$files" "$bytes"
    printf '| PDF | %s |\n| Plain text | %s |\n| LaTeX | %s |\n| Markdown | %s |\n' "$pdfs" "$texts" "$tex" "$markdown"
    printf '| Images | %s |\n| Audio | %s |\n| Video | %s |\n| Code/web files | %s |\n\n' "$images" "$audio" "$video" "$code"
    printf '## Top-level contents\n\n```text\n'
    find "$repository" -mindepth 1 -maxdepth 1 ! -name .git ! -name .cleanup-quarantine \
      ! -path "$output" -printf '%f\t%y\n' | sort
    printf '```\n\n## Largest files\n\n| Bytes | Path |\n|---:|---|\n'
    find_repo -type f -printf '%s\t%P\n' | sort -nr | sed -n '1,40p' | while IFS=$'\t' read -r size path; do
      printf '| %s | `%s` |\n' "$size" "${path//|/\\|}"
    done
    printf '\n## Files by top-level area\n\n| Area | Files | Bytes |\n|---|---:|---:|\n'
    find_repo -type f -printf '%P\t%s\n' | awk -F '\t' '
      { split($1,p,"/"); area=(index($1,"/") ? p[1] : "(repository root)"); n[area]++; b[area]+=$2 }
      END { for (a in n) printf "%s\t%d\t%.0f\n",a,n[a],b[a] }' | sort | while IFS=$'\t' read -r area count size; do
        printf '| `%s` | %s | %s |\n' "$area" "$count" "$size"
      done
  } > "$inventory"
  say "Wrote: ${inventory#"$repository"/}"
}

safe_name() {
  printf '%s' "$1" | tr '/[:space:]' '--' | tr -cd '[:alnum:]_.-'
}

text_candidates() {
  local area=$1
  find "$area" -type d \( -name .git -o -name .cleanup-quarantine -o -name node_modules -o -name __pycache__ \) -prune -o \
    -type f \( -iname 'README' -o -iname 'README.*' -o -iname '*.md' -o -iname '*.markdown' \
      -o -iname '*.txt' -o -iname '*.tex' -o -iname '*.rst' -o -iname '*.org' \
      -o -iname '*.bib' -o -iname 'TODO' -o -iname 'TODO.*' \) -print0
}

build_context() {
  local area=$1 destination=$2 root_only=${3:-false}
  local file relative remaining take used=0
  : > "$destination"
  while IFS= read -r -d '' file; do
    $root_only && [[ $(dirname -- "$file") != "$repository" ]] && continue
    remaining=$((max_chars - used))
    ((remaining <= 0)) && break
    take=$file_chars
    ((take > remaining)) && take=$remaining
    relative=${file#"$repository"/}
    printf '\n===== FILE: %s =====\n' "$relative" >> "$destination"
    head -c "$take" -- "$file" >> "$destination" 2>/dev/null || true
    printf '\n' >> "$destination"
    used=$(wc -c < "$destination")
  done < <(text_candidates "$area")
}

ollama_prompt() {
  local prompt_file=$1 result_file=$2
  if $stream_output; then
    TERM=dumb NO_COLOR=1 ollama run "$model" --nowordwrap < "$prompt_file" \
      | LC_ALL=C sed -u $'s/\033\\[[0-9;?]*[ -\\/]*[@-~]//g' \
      | tee "$result_file"
  else
    TERM=dumb NO_COLOR=1 ollama run "$model" --nowordwrap < "$prompt_file" \
      | LC_ALL=C sed -u $'s/\033\\[[0-9;?]*[ -\\/]*[@-~]//g' \
      > "$result_file"
  fi
}

summarize_area() {
  local label=$1 area=$2 root_only=${3:-false}
  local slug context prompt summary state newest_input
  slug=$(safe_name "$label")
  context=$output/state/$slug.context.txt
  prompt=$output/state/$slug.prompt.txt
  summary=$output/projects/$slug.md
  state=$output/state/$slug.stamp
  build_context "$area" "$context" "$root_only"
  [[ -s $context ]] || { say "Skipping $label: no readable text sources."; return; }

  newest_input=$(text_candidates "$area" | xargs -0 -r stat -c '%Y' | awk 'm<$1 {m=$1} END {print m+0}')
  newest_input=${newest_input:-0}
  if ! $force && [[ -s $summary && -s $state ]] && [[ $(<"$state") == "$newest_input:$model:$max_chars:$file_chars" ]]; then
    say "Current: projects/$slug.md"
    return
  fi

  {
    cat <<EOF
You are surveying one area of a heterogeneous research and creative repository.
Write a grounded Markdown briefing titled "# $label". Rely only on the supplied
file excerpts. Distinguish explicit evidence from inference. Explain the area's
purpose, principal documents or artifacts, recurring concepts, implementation
state, relationships among files, apparent unfinished work, duplication or
organizational problems, and the most useful next actions. Mention filenames as
evidence. Do not invent claims to fill missing context. Keep the result between
500 and 1,200 words.

Repository excerpts follow:
EOF
    cat "$context"
  } > "$prompt"

  say "Summarizing with $model: $label"
  if ollama_prompt "$prompt" "$summary.tmp" 2>>"$log"; then
    mv -- "$summary.tmp" "$summary"
    printf '%s' "$newest_input:$model:$max_chars:$file_chars" > "$state"
  else
    rm -f -- "$summary.tmp"
    say "Failed: $label"
  fi
}

run_summaries() {
  command -v ollama >/dev/null || die 'ollama is required for summaries.'
  ollama show "$model" >/dev/null 2>&1 || die "Ollama model is unavailable: $model"

  local dir label combined prompt overview
  if $root_summary; then
    summarize_area 'Repository root' "$repository" true
  fi
  while IFS= read -r -d '' dir; do
    [[ $dir == "$output" ]] && continue
    label=$(basename -- "$dir")
    summarize_area "$label" "$dir"
  done < <(find "$repository" -mindepth 1 -maxdepth 1 -type d ! -name .git ! -name .cleanup-quarantine -print0 | sort -z)

  combined=$output/state/all-project-summaries.txt
  : > "$combined"
  while IFS= read -r -d '' summary; do
    printf '\n===== PROJECT SUMMARY: %s =====\n' "$(basename -- "$summary")" >> "$combined"
    cat "$summary" >> "$combined"
  done < <(find "$output/projects" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

  overview=$output/REPOSITORY-OVERVIEW.md
  prompt=$output/state/repository.prompt.txt
  {
    cat <<'EOF'
Synthesize the following project briefings into a repository-wide Markdown
overview titled "# Repository Overview". Explain the repository's identity and
major research or creative programs, group related areas, identify important
cross-project themes and duplicated artifacts, assess navigability and maturity,
and finish with a prioritized maintenance and documentation roadmap. Preserve
uncertainty and cite project or file names. Do not merely concatenate summaries.
Aim for 1,000 to 2,000 words.

EOF
    head -c $((max_chars * 2)) "$combined"
  } > "$prompt"
  say "Synthesizing repository overview with $model"
  ollama_prompt "$prompt" "$overview.tmp" 2>>"$log" || die 'Repository overview synthesis failed.'
  mv -- "$overview.tmp" "$overview"
  say "Wrote: ${overview#"$repository"/}"
}

case $mode in
  extract) extract_pdfs ;;
  inventory) extract_pdfs; write_inventory ;;
  summaries) write_inventory; run_summaries ;;
  all) extract_pdfs; write_inventory; run_summaries ;;
esac

say "Done. Reports are in $output"
