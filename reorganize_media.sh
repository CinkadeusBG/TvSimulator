#!/bin/bash
# =============================================================================
# reorganize_media.sh
# Reorganizes /srv/smb/media for use with TvSimulator (FieldStation42)
#
# What this script does:
#   1. Renames each call-sign directory to a show name
#   2. Creates a tag subdirectory inside (required by TvSimulator)
#   3. Moves all .mp4, .json, .mkv, .webm files into the tag subdirectory
#   4. Leaves commercials/ and artifacts/ untouched
#   5. Leaves any .log files in place
#
# After running, configure each TvSimulator station with absolute paths, e.g.:
#   "content_dir": "/srv/smb/media/ds9"       (tags: "ds9")
#   "content_dir": "/srv/smb/media/cheers"    (tags: "cheers")
#   "commercial_dir": "/srv/smb/media/commercials"
#   "off_air_video": "/srv/smb/media/artifacts/static.mp4"
# =============================================================================

MEDIA_DIR="/srv/smb/media"

# Abort if media directory doesn't exist
if [ ! -d "$MEDIA_DIR" ]; then
    echo "ERROR: Media directory not found: $MEDIA_DIR"
    exit 1
fi

# -----------------------------------------------------------------------------
# Function: process_channel
#   $1 = old call-sign directory name (e.g., KDSN)
#   $2 = new show directory name      (e.g., ds9)
#   $3 = tag subdirectory name        (e.g., ds9)
# -----------------------------------------------------------------------------
process_channel() {
    local old_name="$1"
    local new_name="$2"
    local tag="$3"

    local old_path="$MEDIA_DIR/$old_name"
    local new_path="$MEDIA_DIR/$new_name"
    local tag_path="$new_path/$tag"

    echo ""
    echo "----------------------------------------------------------------------"
    echo "Processing: $old_name  →  $new_name/$tag/"

    # Check source exists
    if [ ! -d "$old_path" ]; then
        echo "  WARNING: Source directory not found, skipping: $old_path"
        return
    fi

    # Step 1: Rename the call-sign directory to the show name
    if [ "$old_name" != "$new_name" ]; then
        mv "$old_path" "$new_path"
        echo "  Renamed: $old_name → $new_name"
    else
        echo "  (No rename needed, directory already named correctly)"
    fi

    # Step 2: Create the tag subdirectory
    mkdir -p "$tag_path"
    echo "  Created: $new_name/$tag/"

    # Step 3: Move all media files into the tag subdirectory
    local count=0
    find "$new_path" -maxdepth 1 -type f \( \
        -iname "*.mp4" -o \
        -iname "*.json" -o \
        -iname "*.mkv" -o \
        -iname "*.webm" \
    \) | while IFS= read -r file; do
        mv "$file" "$tag_path/"
        count=$((count + 1))
    done

    local moved
    moved=$(find "$tag_path" -maxdepth 1 -type f | wc -l)
    echo "  Moved $moved files into $new_name/$tag/"
    echo "  Done: $new_name/$tag/"
}

# =============================================================================
# Main: Process all channel directories
# =============================================================================

echo "============================================================"
echo "  TvSimulator Media Reorganization Script"
echo "  Media directory: $MEDIA_DIR"
echo "============================================================"

#            OLD NAME    NEW NAME             TAG SUBDIR
process_channel "KDSN"   "ds9"               "ds9"
process_channel "KFTS"   "family-ties"       "family-ties"
process_channel "KLIS"   "lost-in-space"     "lost-in-space"
process_channel "KQLP"   "quantum-leap"      "quantum-leap"
process_channel "KTOS"   "tos"               "tos"
process_channel "KVOY"   "voyager"           "voyager"
process_channel "WAGS"   "andy-griffith"     "andy-griffith"
process_channel "WATM"   "a-team"            "a-team"
process_channel "WCHS"   "cheers"            "cheers"
process_channel "WGGS"   "golden-girls"      "golden-girls"
process_channel "WKRD"   "knight-rider"      "knight-rider"
process_channel "WMOV"   "star-trek-movies"  "movies"
process_channel "WMSH"   "mash"              "mash"
process_channel "WTLZ"   "twilight-zone"     "twilight-zone"
process_channel "WTNG"   "tng"               "tng"
process_channel "TWC"    "weather-channel"   "weather-channel"

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "============================================================"
echo "  Reorganization complete!"
echo "============================================================"
echo ""
echo "New structure in $MEDIA_DIR:"
echo ""
echo "  ds9/ds9/                  ← Star Trek: Deep Space Nine"
echo "  family-ties/family-ties/  ← Family Ties"
echo "  lost-in-space/lost-in-space/ ← Lost in Space"
echo "  quantum-leap/quantum-leap/ ← Quantum Leap"
echo "  tos/tos/                  ← Star Trek: The Original Series"
echo "  voyager/voyager/          ← Star Trek: Voyager"
echo "  andy-griffith/andy-griffith/ ← The Andy Griffith Show"
echo "  a-team/a-team/            ← The A-Team"
echo "  cheers/cheers/            ← Cheers"
echo "  golden-girls/golden-girls/ ← The Golden Girls"
echo "  knight-rider/knight-rider/ ← Knight Rider"
echo "  star-trek-movies/movies/  ← Star Trek Movies"
echo "  mash/mash/                ← M*A*S*H"
echo "  twilight-zone/twilight-zone/ ← The Twilight Zone"
echo "  tng/tng/                  ← Star Trek: The Next Generation"
echo "  weather-channel/weather-channel/ ← The Weather Channel"
echo "  commercials/              ← (unchanged) TV Commercials"
echo "  artifacts/                ← (unchanged) static.mp4, etc."
echo ""
echo "TvSimulator station config paths to use:"
echo "  \"content_dir\": \"/srv/smb/media/<show-dir>\""
echo "  \"commercial_dir\": \"/srv/smb/media/commercials\""
echo "  \"off_air_video\": \"/srv/smb/media/artifacts/static.mp4\""
echo ""
