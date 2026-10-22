#!/usr/bin/env bash
# Keeps a project folder in step with its own repo, as a squashed git subtree.
#
#   scripts/subtree.sh pull <project> [repo-url] [branch]
#       Bring the repo's latest into <project>/.
#   scripts/subtree.sh add <project> [repo-url] [branch]
#       Make <project>/ a subtree of the repo. If the folder is already here as
#       plain files, it is removed in one commit and added back from the repo.
#
# The repo defaults to https://github.com/jiminikiz/<project>, the branch to main.
set -euo pipefail

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

[ $# -ge 2 ] || usage
cmd=$1 project=${2%/}
url=${3:-https://github.com/jiminikiz/$project}
branch=${4:-main}

cd "$(git rev-parse --show-toplevel)"

if [ -e .git/MERGE_HEAD ]; then
  echo "A merge is still in progress. Finish it (git commit) or abort it first." >&2
  exit 1
fi
if [ -n "$(git status --porcelain)" ]; then
  echo "There are uncommitted changes. Commit or stash them first." >&2
  exit 1
fi

# the last upstream commit this folder was squashed from, if any
last_split() {
  git log -1 --grep="^git-subtree-dir: $project\$" --format=%B | sed -n 's/^git-subtree-split: //p'
}

case $cmd in
  pull)
    before=$(last_split)
    if [ -z "$before" ]; then
      echo "$project/ isn't a subtree yet. Use: $0 add $project" >&2
      exit 1
    fi
    git subtree pull --prefix="$project" "$url" "$branch" --squash \
      -m "$project: pull the latest from $url"
    after=$(git rev-parse FETCH_HEAD)
    if [ "$before" = "$after" ]; then
      echo "$project/ was already up to date."
    else
      echo; echo "New in $project/:"
      git log --oneline "$before..$after"
    fi
    ;;
  add)
    if [ -n "$(last_split)" ]; then
      echo "$project/ is already a subtree. Use: $0 pull $project" >&2
      exit 1
    fi
    if [ -e "$project" ]; then
      git rm -rq "$project"
      git commit -q -m "$project: remove the copy, to bring it back as a subtree of $url"
    fi
    git subtree add --prefix="$project" "$url" "$branch" --squash \
      -m "$project: add as a subtree of $url"
    ;;
  *)
    usage
    ;;
esac
