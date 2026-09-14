#!/usr/bin/env bash
set -euo pipefail

PROFILE_NAME="${1:-}"
TARGET_DIR="${2:-$(pwd)}"
PROFILES_DIR="${PI_PROFILES_DIR:-/home/jerry/.pi/agent/packages}"

if [ -z "$PROFILE_NAME" ]; then
  echo "Usage: configure.sh <profile-name> [target-dir]"
  echo ""
  echo "Environment variables:"
  echo "  PI_PROFILES_DIR - directory containing profiles.json (default: $PROFILES_DIR)"
  echo ""
  echo "Available profiles:"
  if [ -f "$PROFILES_DIR/profiles.json" ]; then
    jq -r 'keys[] as $k | "  - \($k): \(.[$k].description // "no description")"' "$PROFILES_DIR/profiles.json"
  fi
  exit 1
fi

PROFILES_JSON="$PROFILES_DIR/profiles.json"

if [ ! -f "$PROFILES_JSON" ]; then
  echo "Error: profiles.json not found at $PROFILES_JSON"
  echo "Set PI_PROFILES_DIR to the directory containing your profiles.json"
  exit 1
fi

# ---------------------------------------------------------------------------
# Resolve profile → list of source directories
# ---------------------------------------------------------------------------

# Check if profile exists
PROFILE_EXISTS=$(jq -r "has(\"$PROFILE_NAME\")" "$PROFILES_JSON")
if [ "$PROFILE_EXISTS" != "true" ]; then
  echo "Error: profile '$PROFILE_NAME' not found in $PROFILES_JSON"
  echo ""
  echo "Available profiles:"
  jq -r 'keys[] as $k | "  - \($k): \(.[$k].description // "no description")"' "$PROFILES_JSON"
  exit 1
fi

# Resolve sourceDirs: config file > direct sourceDirs > backward-compat sourceDir
SOURCE_DIRS=""
CONFIG_PATH=$(jq -r ".\"$PROFILE_NAME\".config // empty" "$PROFILES_JSON")

if [ -n "$CONFIG_PATH" ]; then
  CONFIG_FILE="$PROFILES_DIR/$CONFIG_PATH"
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config file not found at $CONFIG_FILE"
    exit 1
  fi
  SOURCE_DIRS=$(jq -r '.sourceDirs // empty | .[]' "$CONFIG_FILE" 2>/dev/null || true)
  if [ -z "$SOURCE_DIRS" ]; then
    echo "Error: config file $CONFIG_FILE has no 'sourceDirs' array"
    exit 1
  fi
else
  DIRECT_DIRS=$(jq -r ".\"$PROFILE_NAME\".sourceDirs // empty | .[]" "$PROFILES_JSON" 2>/dev/null || true)
  if [ -n "$DIRECT_DIRS" ]; then
    SOURCE_DIRS="$DIRECT_DIRS"
  else
    SINGLE_DIR=$(jq -r ".\"$PROFILE_NAME\".sourceDir // empty" "$PROFILES_JSON")
    if [ -n "$SINGLE_DIR" ]; then
      SOURCE_DIRS="$SINGLE_DIR"
    else
      echo "Error: profile '$PROFILE_NAME' has no sourceDirs, config, or sourceDir"
      exit 1
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Always include common profile as the base layer
# ---------------------------------------------------------------------------
if [ "$PROFILE_NAME" != "common" ]; then
  COMMON_SOURCE=$(jq -r '.common.sourceDir // empty' "$PROFILES_JSON")
  if [ -n "$COMMON_SOURCE" ]; then
    # Deduplicate: don't add common if already in the list
    if ! echo "$SOURCE_DIRS" | grep -qxF "$COMMON_SOURCE"; then
      SOURCE_DIRS="$COMMON_SOURCE"$'\n'"$SOURCE_DIRS"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Validate all source directories
# ---------------------------------------------------------------------------

TARGET_PI="$TARGET_DIR/.pi"
mkdir -p "$TARGET_PI"

declare -a SOURCE_PIS=()
for dir in $SOURCE_DIRS; do
  source_pi="$PROFILES_DIR/$dir/.pi"
  if [ ! -d "$source_pi" ]; then
    # Some sources might only have a skill directory, not a .pi dir
    if [ -d "$PROFILES_DIR/$dir" ]; then
      # Source dir exists but no .pi — might be a skill-only directory
      # In that case, check for a skills/ subdirectory directly
      if [ -d "$PROFILES_DIR/$dir/skills" ]; then
        echo "Note: $dir has no .pi/ but has skills/. Treating as skill source."
        # We'll handle this specially later
        SOURCE_PIS+=("$PROFILES_DIR/$dir")
        continue
      fi
    fi
    echo "Warning: source .pi directory not found at $source_pi (skipping)"
    continue
  fi
  SOURCE_PIS+=("$source_pi")
done

if [ ${#SOURCE_PIS[@]} -eq 0 ]; then
  echo "Error: no valid source directories found for profile '$PROFILE_NAME'"
  exit 1
fi

# ---------------------------------------------------------------------------
# Merge settings.json from all sources
# ---------------------------------------------------------------------------

# Collect all source settings.json files
SETTINGS_FILES=()
for src in "${SOURCE_PIS[@]}"; do
  if [ -f "$src/settings.json" ]; then
    SETTINGS_FILES+=("$src/settings.json")
  fi
done

if [ ${#SETTINGS_FILES[@]} -gt 0 ]; then
  # Merge all source settings: arrays concatenate and dedup, scalars: first wins,
  # object keys (observational-memory) shallow-merge with later values winning
  COMBINED_SETTINGS=$(jq -s '
    reduce .[] as $item ({};
      {
        packages: (((.packages // []) + ($item.packages // [])) | unique),
        skills: (((.skills // []) + ($item.skills // [])) | unique),
        extensions: (((.extensions // []) + ($item.extensions // [])) | unique),
        "observational-memory": ((."observational-memory" // {}) + ($item."observational-memory" // {}))
      } + (. | del(.packages, .skills, .extensions, ."observational-memory")) + ($item | del(.packages, .skills, .extensions, ."observational-memory"))
    )
  ' "${SETTINGS_FILES[@]}")

  # Now merge combined settings into target's existing settings.json
  if [ -f "$TARGET_PI/settings.json" ]; then
    echo "Merging settings.json (existing config preserved)..."
    cp "$TARGET_PI/settings.json" "$TARGET_PI/settings.json.bak"
    echo "$COMBINED_SETTINGS" | jq -s '
      .[0] as $source | .[1] as $target |
      reduce ($source | keys_unsorted[]) as $k (
        $target;
        if $k == "packages" or $k == "skills" or $k == "extensions" then
          .[$k] = (((.[$k] // []) + ($source[$k] // [])) | unique)
        elif $k == "observational-memory" then
          .[$k] = (($source[$k] // {}) + (.[$k] // {}))
        else
          .[$k] = (.[$k] // $source[$k])
        end
      )
    ' - "$TARGET_PI/settings.json" > "$TARGET_PI/settings.json.tmp"
    mv "$TARGET_PI/settings.json.tmp" "$TARGET_PI/settings.json"
  else
    echo "$COMBINED_SETTINGS" > "$TARGET_PI/settings.json"
  fi
fi

# ---------------------------------------------------------------------------
# Merge directories from all sources
# ---------------------------------------------------------------------------

merge_dir() {
  local src_dir="$1"
  local target_dir="$2"
  local dir_name="$3"

  if [ ! -d "$src_dir/$dir_name" ]; then
    return 0
  fi

  mkdir -p "$target_dir/$dir_name"

  for item in "$src_dir/$dir_name"/*; do
    [ -e "$item" ] || continue
    local name=$(basename "$item")
    if [ ! -e "$target_dir/$dir_name/$name" ]; then
      cp -r "$item" "$target_dir/$dir_name/$name"
    fi
  done
}

copy_if_missing() {
  local src="$1"
  local target="$2"
  if [ -e "$src" ] && [ ! -e "$target" ]; then
    cp -r "$src" "$target"
  fi
}

for src in "${SOURCE_PIS[@]}"; do
  # npm: only copy if target doesn't have it yet (first source wins)
  if [ -d "$src/npm" ] && [ ! -d "$TARGET_PI/npm" ]; then
    cp -r "$src/npm" "$TARGET_PI/npm"
    echo "Copied npm packages from $(dirname "$src")"
  fi

  # skills: merge (don't overwrite existing)
  merge_dir "$src" "$TARGET_PI" "skills"

  # extensions: merge (don't overwrite existing)
  merge_dir "$src" "$TARGET_PI" "extensions"

  # Copy any other files/directories (excluding handled ones)
  for item in "$src"/*; do
    [ -e "$item" ] || continue
    name=$(basename "$item")
    case "$name" in
      settings.json|npm|skills|extensions) continue ;;
    esac
    copy_if_missing "$item" "$TARGET_PI/$name"
  done
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "✓ Project configured for profile: $PROFILE_NAME"
echo "  Target: $TARGET_PI"
echo "  Sources:"
for src in "${SOURCE_PIS[@]}"; do
  echo "    - $(dirname "$src")"
done
echo ""
if [ -f "$TARGET_PI/settings.json" ]; then
  echo "Packages configured:"
  jq -r '.packages // [] | .[]' "$TARGET_PI/settings.json" | sed 's/^/  - /'
  echo ""
  echo "Skills configured:"
  if [ -d "$TARGET_PI/skills" ]; then
    find "$TARGET_PI/skills" -maxdepth 1 -type d | while read -r d; do
      [ "$d" = "$TARGET_PI/skills" ] && continue
      echo "  - $(basename "$d")"
    done
  fi
  echo ""
  echo "Extensions configured:"
  if [ -d "$TARGET_PI/extensions" ]; then
    find "$TARGET_PI/extensions" -maxdepth 1 -type f | while read -r f; do
      echo "  - $(basename "$f")"
    done
  fi
else
  echo "No settings.json configured."
fi
