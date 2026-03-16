#!/bin/bash
# =============================================================================
# fix_media_folders.sh
# Fixes the double-folder structure created by reorganize_media.sh.
#
# Moves files from  <show>/<tag>/*  up to  <show>/*
# then removes the now-empty inner tag subdirectory.
#
# Result: /srv/smb/media/<show>/  contains episode files directly.
#
# After running, use this in ALL TvSimulator station configs:
#   "content_dir": "/srv/smb/media"
#
# Then each station's schedule tags match the show folder name:
#   DS9 station:          "tags": "ds9"
#   Cheers station:       "tags": "cheers"
#   M*A*S*H station:      "tags": "mash"
#   TNG station:          "tags": "tng"
#   ... etc.
# =============================================================================

MEDIA_DIR="/srv/smb/media"

# Abort if media directory doesn't exist
if [ ! -d "$MEDIA_DIR" ]; then
    echo "ERROR: Media directory not found: $MEDIA_DIR"
    exit 1
fi

# -----------------------------------------------------------------------------
# Function: flatten_show
#   $1 = show directory name  (e.g., ds9)
#   $2 = tag subdirectory name inside it  (e.g., ds9)
# -----------------------------------------------------------------------------
flatten_show() {
    local show="$1"
    local tag="$2"

    local show_path="$MEDIA_DIR/$show"
    local tag_path="$show_path/$tag"

    echo ""
    echo "----------------------------------------------------------------------"
    echo "Flattening: $show/$tag/  →  $show/"

    # Check show directory exists
    if [ ! -d "$show_path" ]; then
        echo "  WARNING: Show directory not found, skipping: $show_path"
        return
    fi

    # Check tag subdirectory exists
    if [ ! -d "$tag_path" ]; then
        echo "  WARNING: Tag subdirectory not found, skipping: $tag_path"
        return
    fi

    # Move all files from the tag subdir up to the show dir
    local moved=0
    find "$tag_path" -maxdepth 1 -type f | while IFS= read -r file; do
        mv "$file" "$show_path/"
        moved=$((moved + 1))
    done

    # Remove the now-empty tag subdirectory
    if [ -d "$tag_path" ]; then
        rmdir "$tag_path" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  Removed empty subdirectory: $show/$tag/"
        else
            echo "  WARNING: Could not remove $show/$tag/ — may not be empty"
        fi
    fi

    local count
    count=$(find "$show_path" -maxdepth 1 -type f | wc -l)
    echo "  Done: $show/ now contains $count files"
}

# =============================================================================
# Main: Flatten all show directories
# =============================================================================

echo "============================================================"
echo "  TvSimulator Media Folder Fix Script"
echo "  Media directory: $MEDIA_DIR"
echo "============================================================"

#           SHOW DIR            TAG SUBDIR
flatten_show "ds9"               "ds9"
flatten_show "family-ties"       "family-ties"
flatten_show "lost-in-space"     "lost-in-space"
flatten_show "quantum-leap"      "quantum-leap"
flatten_show "tos"               "tos"
flatten_show "voyager"           "voyager"
flatten_show "andy-griffith"     "andy-griffith"
flatten_show "a-team"            "a-team"
flatten_show "cheers"            "cheers"
flatten_show "golden-girls"      "golden-girls"
flatten_show "knight-rider"      "knight-rider"
flatten_show "star-trek-movies"  "movies"
flatten_show "mash"              "mash"
flatten_show "twilight-zone"     "twilight-zone"
flatten_show "tng"               "tng"
flatten_show "weather-channel"   "weather-channel"

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "============================================================"
echo "  Fix complete!"
echo "============================================================"
echo ""
echo "Final structure in $MEDIA_DIR:"
echo ""
echo "  ds9/                ← Star Trek: Deep Space Nine (files directly here)"
echo "  family-ties/        ← Family Ties"
echo "  lost-in-space/      ← Lost in Space"
echo "  quantum-leap/       ← Quantum Leap"
echo "  tos/                ← Star Trek: The Original Series"
echo "  voyager/            ← Star Trek: Voyager"
echo "  andy-griffith/      ← The Andy Griffith Show"
echo "  a-team/             ← The A-Team"
echo "  cheers/             ← Cheers"
echo "  golden-girls/       ← The Golden Girls"
echo "  knight-rider/       ← Knight Rider"
echo "  star-trek-movies/   ← Star Trek Movies"
echo "  mash/               ← M*A*S*H"
echo "  twilight-zone/      ← The Twilight Zone"
echo "  tng/                ← Star Trek: The Next Generation"
echo "  weather-channel/    ← The Weather Channel"
echo "  commercials/        ← TV Commercials (unchanged)"
echo "  artifacts/          ← static.mp4 etc. (unchanged)"
echo ""
echo "Use this in ALL TvSimulator station configs:"
echo "  \"content_dir\": \"/srv/smb/media\""
echo "  \"commercial_dir\": \"/srv/smb/media/commercials\""
echo "  \"off_air_video\": \"/srv/smb/media/artifacts/static.mp4\""
echo ""
echo "Schedule tags match folder names:"
echo "  DS9:          \"tags\": \"ds9\""
echo "  Cheers:       \"tags\": \"cheers\""
echo "  M*A*S*H:      \"tags\": \"mash\""
echo "  TNG:          \"tags\": \"tng\""
echo "  Movies:       \"tags\": \"star-trek-movies\""
echo "  (etc.)"
echo ""
