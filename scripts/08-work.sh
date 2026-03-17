#!/usr/bin/env bash
# Optional work bootstrap — clones/updates a work dotfiles repo and runs its install

if [ -z "$WORK_REPO" ]; then
  echo "    No --work repo specified, skipping"
  exit 0
fi

# Resolve WORK_REPO to a local directory
if [[ "$WORK_REPO" == /* || "$WORK_REPO" == ~* ]]; then
  # Absolute or home-relative path — use directly
  WORK_DIR="${WORK_REPO/#\~/$HOME}"
elif [ -d "$HOME/dev/github.com/$WORK_REPO" ]; then
  # org/repo shorthand — found locally
  WORK_DIR="$HOME/dev/github.com/$WORK_REPO"
  echo "    Found $WORK_REPO locally at $WORK_DIR"
else
  # org/repo shorthand — clone it
  WORK_DIR="$HOME/dev/github.com/$WORK_REPO"
  echo "    Cloning $WORK_REPO..."
  mkdir -p "$(dirname "$WORK_DIR")"
  git clone "git@github.com:$WORK_REPO.git" "$WORK_DIR"
fi

# Update if it's a git repo
if [ -d "$WORK_DIR/.git" ]; then
  echo "    Updating $WORK_DIR..."
  git -C "$WORK_DIR" pull --ff-only
fi

if [ ! -f "$WORK_DIR/install.sh" ]; then
  echo "    No install.sh found in $WORK_DIR, skipping"
  exit 0
fi

echo "    Running work install from $WORK_DIR..."
bash "$WORK_DIR/install.sh"
