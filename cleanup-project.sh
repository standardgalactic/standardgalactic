#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: cleanup-project.sh [OPTIONS] [DIRECTORY]

Preview or quarantine regenerable project clutter. DIRECTORY defaults to the
current directory. Nothing is changed unless --apply or --purge is supplied.

Options:
  --apply             Move matched items into .cleanup-quarantine/TIMESTAMP/
  --purge             Permanently delete the entire quarantine directory
  --latex             Include LaTeX build files (default)
  --blender-backups   Include numbered Blender backups: *.blend1, *.blend2, ...
  --blender-caches    Include Blender cache_* directories
  --inventory-files   Include generated directory/file listings
  --all               Enable every cleanup category
  -h, --help          Show this help

Examples:
  ./cleanup-project.sh
  ./cleanup-project.sh --all /path/to/project
  ./cleanup-project.sh --all --apply /path/to/project
  ./cleanup-project.sh --purge /path/to/project
EOF
}

apply=false
purge=false
latex=true
blender_backups=false
blender_caches=false
inventory_files=false
target=.

while (($#)); do
  case $1 in
    --apply) apply=true ;;
    --purge) purge=true ;;
    --latex) latex=true ;;
    --blender-backups) blender_backups=true ;;
    --blender-caches) blender_caches=true ;;
    --inventory-files) inventory_files=true ;;
    --all)
      latex=true
      blender_backups=true
      blender_caches=true
      inventory_files=true
      ;;
    -h|--help) usage; exit 0 ;;
    --*) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ $target != . ]]; then
        printf 'Only one directory may be supplied.\n' >&2
        exit 2
      fi
      target=$1
      ;;
  esac
  shift
done

target=$(realpath -- "$target")
[[ -d $target ]] || { printf 'Not a directory: %s\n' "$target" >&2; exit 1; }

quarantine_root=$target/.cleanup-quarantine

if $purge; then
  if $apply; then
    printf '%s\n' '--apply and --purge cannot be used together.' >&2
    exit 2
  fi
  if [[ ! -d $quarantine_root ]]; then
    printf 'No quarantine directory exists at %s\n' "$quarantine_root"
    exit 0
  fi
  printf 'Permanently removing %s\n' "$quarantine_root"
  rm -rf -- "$quarantine_root"
  exit 0
fi

declare -a find_args=("$target" -path "$quarantine_root" -prune -o \( -false)

if $latex; then
  find_args+=( -o -type f \( \
    -name '*.aux' -o -name '*.bbl' -o -name '*.bcf' -o -name '*.blg' \
    -o -name '*.fdb_latexmk' -o -name '*.fls' -o -name '*.glg' \
    -o -name '*.glo' -o -name '*.gls' -o -name '*.ist' -o -name '*.lof' \
    -o -name '*.log' -o -name '*.lot' -o -name '*.nav' -o -name '*.out' \
    -o -name '*.run.xml' -o -name '*.snm' -o -name '*.synctex.gz' \
    -o -name '*.toc' -o -name '*.vrb' \
  \) )
fi

if $blender_backups; then
  find_args+=( -o -type f -regextype posix-extended -regex '.*\.blend[0-9]+' )
fi

if $blender_caches; then
  find_args+=( -o -type d -name 'cache_*' )
fi

if $inventory_files; then
  find_args+=( -o -type f \( \
    -name 'directory-tree.txt' -o -name 'file-list.txt' -o -name 'file-tree.txt' \
    -o -name 'file-overview.txt' -o -name 'file.list' \
    -o -name 'holistic-overview.txt' -o -name 'user-overview.txt' \
  \) )
fi

find_args+=( \) -print0 )

mapfile -d '' matches < <(find "${find_args[@]}")

if ((${#matches[@]} == 0)); then
  printf 'No matching clutter found under %s\n' "$target"
  exit 0
fi

printf '%s %d matched item(s) under %s:\n' "$($apply && printf 'Quarantining' || printf 'Would quarantine')" "${#matches[@]}" "$target"
for path in "${matches[@]}"; do
  printf '  %q\n' "${path#"$target"/}"
done

if ! $apply; then
  printf '\nDry run only. Add --apply to move these items into quarantine.\n'
  exit 0
fi

stamp=$(date -u +'%Y%m%dT%H%M%SZ')
destination=$quarantine_root/$stamp

for source in "${matches[@]}"; do
  relative=${source#"$target"/}
  mkdir -p -- "$destination/$(dirname -- "$relative")"
  mv -- "$source" "$destination/$relative"
done

printf '\nMoved %d item(s) to %s\n' "${#matches[@]}" "$destination"
printf 'Inspect that directory, then use --purge when you no longer need it.\n'
