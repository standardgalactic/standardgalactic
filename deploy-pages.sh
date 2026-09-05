#!/usr/bin/env bash
set -uo pipefail

OWNER="standardgalactic"

REPOS=(
    history
    admissibility-lab
    textbook
    philosophy
    epistemology
    intelligence
    photonics
    rsvp-lab
)

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: gh is not installed."
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "ERROR: gh is not authenticated."
    exit 1
fi

echo "GitHub Pages batch deployment"
echo "============================="
echo

SUCCESS=()
FAILED=()
ALREADY=()

for repo in "${REPOS[@]}"; do
    echo
    echo "------------------------------------------------------------"
    echo "$OWNER/$repo"
    echo "------------------------------------------------------------"

    # Make sure repository exists.
    if ! gh repo view "$OWNER/$repo" >/dev/null 2>&1; then
        echo "ERROR: repository does not exist."
        FAILED+=("$repo")
        continue
    fi

    # Find its default branch.
    branch="$(
        gh api "repos/$OWNER/$repo" \
            --jq '.default_branch' 2>/dev/null
    )"

    if [[ -z "$branch" || "$branch" == "null" ]]; then
        echo "ERROR: couldn't determine default branch."
        FAILED+=("$repo")
        continue
    fi

    echo "Default branch: $branch"

    # See whether Pages already exists.
    if gh api "repos/$OWNER/$repo/pages" >/dev/null 2>&1; then
        echo "Pages already configured."

        # Make sure it points at the repository root/default branch.
        if gh api \
            --method PUT \
            "repos/$OWNER/$repo/pages" \
            -f "source[branch]=$branch" \
            -f "source[path]=/" \
            >/dev/null
        then
            echo "Pages source updated: $branch /"
            ALREADY+=("$repo")
        else
            echo "ERROR: couldn't update Pages configuration."
            FAILED+=("$repo")
        fi

        continue
    fi

    echo "Enabling Pages from $branch / ..."

    if gh api \
        --method POST \
        "repos/$OWNER/$repo/pages" \
        -f "source[branch]=$branch" \
        -f "source[path]=/" \
        >/dev/null
    then
        echo "Pages enabled."
        SUCCESS+=("$repo")
    else
        echo "ERROR: Pages configuration failed."
        FAILED+=("$repo")
    fi
done

echo
echo
echo "============================================================"
echo "RESULTS"
echo "============================================================"

if ((${#SUCCESS[@]})); then
    echo
    echo "Newly enabled:"
    printf '  https://standardgalactic.github.io/%s/\n' "${SUCCESS[@]}"
fi

if ((${#ALREADY[@]})); then
    echo
    echo "Already configured / updated:"
    printf '  https://standardgalactic.github.io/%s/\n' "${ALREADY[@]}"
fi

if ((${#FAILED[@]})); then
    echo
    echo "Failed:"
    printf '  %s\n' "${FAILED[@]}"
fi

echo
echo "GitHub may need several minutes to build the sites."
