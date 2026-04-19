#!/usr/bin/env bash
set -euo pipefail

REPLACEMENT="Flyxion"
LOG_FILE="flyxion_corrections.log"
CANDIDATE_FILE="$(mktemp)"
VIM_SCRIPT="$(mktemp)"

PATTERN='Flexion|Flixian|Flixing|Fliction|Flippshen|Flexumian|Fletchian|Flicksheen|Flyzion|Flyxen|Flyxian|Flyxionn|Flyxionne|Flykshun|Flykshion|Flikshun|Flikzion|Flikxion|Flixion|Fleksion|Fleksian|Flextion|Flicksion|Flickzion|Flickxion|Flickshank|Fleksheen|Flekshun|Flekzion|Flixion|Flixyon|Flixxon|Flixionne|Felician|Flyxionu|Flick Sheenan|Flixan|Fugchin|Flickshen|Flickshin'

cleanup() {
  rm -f "$CANDIDATE_FILE" "$VIM_SCRIPT"
}
trap cleanup EXIT

############################################
# Backup snapshot
############################################

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="backup_$TIMESTAMP"

echo "Creating backup snapshot: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

while IFS= read -r -d '' file; do
  mkdir -p "$BACKUP_DIR/$(dirname "$file")"
  cp "$file" "$BACKUP_DIR/$file"
done < <(find . -type f \( \
  -name "*.json" -o -name "*.srt" -o -name "*.tsv" -o -name "*.txt" -o -name "*.vtt" \
\) ! -path "./backup_*/*" -print0)

echo "Backup complete."

############################################
# Logging init
############################################

echo "" >> "$LOG_FILE"
echo "Flyxion normalization log - $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

############################################
# Interactive affliction disambiguation
############################################

echo "---- Interactive disambiguation: affliction (txt only) ----"

while IFS= read -r -d '' file; do
  python3 - "$file" <<'PY'
import sys
import re

filename = sys.argv[1]
pattern = re.compile(r'\b[Aa]ffliction\b')

try:
    tty = open("/dev/tty")
except Exception:
    sys.exit(0)

def ask(prompt):
    print(prompt, end='', flush=True)
    return tty.readline().strip().lower()

try:
    with open(filename, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()
except Exception:
    sys.exit(0)

modified = False

for i, line in enumerate(lines):
    if pattern.search(line):
        print("\n---")
        print(f"{filename}:{i+1}")
        print(line.strip())

        while True:
            resp = ask("Is this the name (n) or the concept (c)? [n/c/skip/quit]: ")
            if resp in ("n", "c", "skip", "quit"):
                break

        if resp == "quit":
            sys.exit(0)

        if resp == "n":
            lines[i] = pattern.sub("Flyxion", line)
            modified = True

if modified:
    with open(filename, "w", encoding="utf-8") as f:
        f.writelines(lines)
    print(f"Updated (affliction pass): {filename}")
PY
done < <(find . -type f -name "*.txt" -print0)

############################################
# Vim script (fixed logging)
############################################

cat > "$VIM_SCRIPT" <<EOF
redir! > /dev/stdout
g/\v\c${PATTERN}/echo expand('%:p') . ':' . line('.') . ': ' . getline('.') . ' -> ' . substitute(getline('.'), '\v\c${PATTERN}', '${REPLACEMENT}', 'g')
redir END
%s/\v\c${PATTERN}/${REPLACEMENT}/gi
%s/\v\c(in|of|af|am|an|at|to)(flyxion)/\1 Flyxion/gi
wq!
EOF

############################################
# Main normalization pass
############################################

while IFS= read -r -d '' file; do
  case "$file" in
    *.json|*.srt|*.tsv|*.txt|*.vtt)

      tmp_log="$(mktemp)"

      vim -Es "$file" -S "$VIM_SCRIPT" > "$tmp_log" 2>/dev/null || true

      if [ -s "$tmp_log" ]; then
        cat "$tmp_log" >> "$LOG_FILE"
      else
        echo "[no changes] $file" >> "$LOG_FILE"
      fi

      rm -f "$tmp_log"

      echo "Updated: $file"

      python3 -c '
import sys, difflib, re
target = "flyxion"
threshold = 0.74
filename = sys.argv[1]

with open(filename, "r", errors="ignore") as fh:
    for line in fh:
        for w in re.findall("[A-Za-z]+", line):
            lw = w.lower()
            if (
                lw != target
                and abs(len(lw) - len(target)) <= 2
                and difflib.SequenceMatcher(None, lw, target).ratio() >= threshold
                and (
                    lw.startswith("flyxion")
                    or "xion" in lw
                    or "xen" in lw
                    or "zion" in lw
                )
            ):
                print(lw)
' "$file" >> "$CANDIDATE_FILE"

      ;;
  esac
done < <(find . -type f ! -path "./backup_*/*" -print0)

############################################
# Candidate aggregation
############################################

echo "" >> "$LOG_FILE"

if [ -s "$CANDIDATE_FILE" ]; then
  echo "---- Candidate Variants (aggregated) ----" >> "$LOG_FILE"
  sort "$CANDIDATE_FILE" | uniq -c | sort -nr >> "$LOG_FILE"
else
  echo "---- Candidate Variants (none found) ----" >> "$LOG_FILE"
fi

echo "----------------------------------------" >> "$LOG_FILE"
echo "Done." >> "$LOG_FILE"
