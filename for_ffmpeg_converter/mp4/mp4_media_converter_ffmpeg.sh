#!/bin/bash

#!/bin/bash

# mp4_media_converter_ffmpeg.sh | [.mov] → [.mp4] speed/size converter (no audio)
# macOS + Bash 3.2
#
# ==========================================================================================
#  FFmpeg Media Processor (.mov → .mp4)
# ------------------------------------------------------------------------------------------
# Converts `.mov` or `.mp4` files into compressed `.mp4` format using FFmpeg.
# - Optimized for speed and size reduction
# - Removes audio tracks
# - Lets you control resolution, encoding mode, quality, and logging
#
# Features:
#   • Batch recursive scan of input directory for .mov/.mp4
#   • Adjustable playback speed with --speed (default: 2× faster)
#   • Resize or keep resolution (--width / --keep-size)
#   • CRF (quality-based) or bitrate encoding modes
#   • libx264 codec with adjustable preset
#   • Metadata preserved, +faststart enabled (better web playback)
#   • Customizable logging (--fflog, --stats, --verbose)
#   • Dry-run mode for previewing commands
#
# Defaults:
#   Speed        : 2×
#   Mode         : crf
#   CRF value    : 22
#   Bitrate      : 1500k (if --mode bitrate)
#   Width        : 960 px (auto aspect ratio)
#   Preset       : medium
#   Log level    : error
#   Stats        : off
#   Audio        : removed (-an)
#
# Usage:
#   ./mp4_media_converter_ffmpeg.sh [ args / options ]
#
#   --speed N         Playback speed multiplier (default: 2)
#   --keep-size       Preserve original resolution
#   --width W         Max width (default: 960)
#   --mode MODE       crf | bitrate (default: crf)
#   --crf N           CRF quality (default: 22)
#   --bitrate RATE    Bitrate if mode=bitrate (default: 1500k)
#   --preset P        x264 preset (default: medium)
#   --in DIR          Input directory (default: ./temp_video_inputs)
#   --out DIR         Output directory (default: compressed_<timestamp>)
#   --dry-run         Print FFmpeg commands only
#   --fflog LVL       Log level (quiet|panic|fatal|error|warning|info|verbose|debug|trace)
#   -v LVL            Alias for --fflog
#   --stats           Show encoding progress stats
#   --verbose         Shortcut for --fflog info --stats
#   --no-faststart    Disable +faststart (web optimization)
#   --no-summary      Skip final size summary
#   -h, --help        Show help
#
# Examples:
#   ./mp4_media_converter_ffmpeg.sh --speed 3 --keep-size
#   ./mp4_media_converter_ffmpeg.sh --speed 2 --width 720 --mode crf --crf 23 --preset slow
#   ./mp4_media_converter_ffmpeg.sh --speed 4 --mode bitrate --bitrate 1200k
#   ./mp4_media_converter_ffmpeg.sh --keep-size --fflog info --stats
#   ./mp4_media_converter_ffmpeg.sh --fflog debug --stats
#   ./mp4_media_converter_ffmpeg.sh --fflog quiet --no-summary
#
# How Speed Works:
#   Uses setpts=FACTOR*PTS where FACTOR=1/SPEED
#   Example: --speed 2 → FACTOR=0.5 → video runs 2× faster.
#
# Notes:
#   • Width is clamped to even values (FFmpeg requirement).
#   • Audio always stripped (-an).
#   • faststart rearranges MP4 for faster web streaming.
# ==========================================================================================

set -euo pipefail

# ____________ defaults _____________
TEMP_DIR="./temp_video_inputs"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
OUTPUT_DIR="compressed_${TIMESTAMP}"

DEFAULT_SPEED=2
DEFAULT_WIDTH=960
DEFAULT_MODE="crf"          # crf | bitrate
DEFAULT_CRF=22
DEFAULT_BITRATE="1500k"
DEFAULT_PRESET="medium"

# _____ FFmpeg logging controls:
DEFAULT_FFLOG="error"   # quiet|panic|fatal|error|warning|info|verbose|debug|trace
DEFAULT_STATS=0

print_help() {
  cat <<EOF

FFmpeg Video Speed & Size (No Audio)
------------------------------------
Usage:
  $(basename "$0") [options]

Options:
  --speed N         Playback speed multiplier                  (default: ${DEFAULT_SPEED})
  --keep-size       Preserve original resolution (no scale)
  --width W         Max output width (height auto)             (default: ${DEFAULT_WIDTH})
  --mode MODE       crf|bitrate                                (default: ${DEFAULT_MODE})
  --crf N           CRF quality if mode=crf                    (default: ${DEFAULT_CRF})
  --bitrate RATE    Video bitrate if mode=bitrate              (default: ${DEFAULT_BITRATE})
  --preset P        x264 preset                                (default: ${DEFAULT_PRESET})
  --in DIR          Input dir (recursive scan)                 (default: ${TEMP_DIR})
  --out DIR         Output dir                                 (default: ${OUTPUT_DIR})
  --dry-run         Print commands only

  # FFmpeg verbosity controls
  --fflog LVL       FFmpeg -loglevel (quiet|panic|fatal|error|warning|info|verbose|debug|trace)
  -v LVL            Alias for --fflog LVL
  --stats           Show FFmpeg progress stats (adds -stats)
  --verbose         Convenience: sets --fflog info and --stats (unless you set them yourself)

  --no-faststart    Disable +faststart (avoids longer finalize step)
  --no-summary      Skip final 'du -sh' size summary
  -h|--help         Show this help

Notes:
  • Output: MP4 (H.264), audio is removed (-an).
  • Speed uses setpts=1/speed*PTS.
  • Width is clamped to even to avoid odd-dimension issues.

If you run with NO ARGS, input dir is created and this help is shown.
Place .mov/.mp4 files in: ${TEMP_DIR}

Examples:
  $(basename "$0") --speed 3 --keep-size
  $(basename "$0") --speed 2 --width 720 --mode crf --crf 23 --preset slow
  $(basename "$0") --speed 4 --width 960 --mode bitrate --bitrate 1200k
  $(basename "$0") --keep-size --fflog info --stats
  $(basename "$0") --fflog debug --stats
  $(basename "$0") --fflog quiet --no-summary
EOF
  exit 0
}

# ___ If no args | check input dir exists | show help:
if [[ $# -eq 0 ]]; then
  mkdir -p "$TEMP_DIR"
  echo "[INFO] Created: $TEMP_DIR (drop videos here)"
  print_help
fi

# ===== Parse args =====
SPEED="$DEFAULT_SPEED"
KEEP_SIZE=0
WIDTH="$DEFAULT_WIDTH"
MODE="$DEFAULT_MODE"
CRF="$DEFAULT_CRF"
BITRATE="$DEFAULT_BITRATE"
PRESET="$DEFAULT_PRESET"
IN_DIR="$TEMP_DIR"
OUT_DIR="$OUTPUT_DIR"
DRY_RUN=0
VERBOSE=0
FASTSTART=1
SHOW_SUMMARY=1

FFLOG="$DEFAULT_FFLOG"
STATS="$DEFAULT_STATS"
FFLOG_SET=0
STATS_SET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --speed)        SPEED="$2"; shift 2 ;;
    --keep-size)    KEEP_SIZE=1; shift ;;
    --width)        WIDTH="$2"; shift 2 ;;
    --mode)         MODE="$2"; shift 2 ;;
    --crf)          CRF="$2"; shift 2 ;;
    --bitrate)      BITRATE="$2"; shift 2 ;;
    --preset)       PRESET="$2"; shift 2 ;;
    --in)           IN_DIR="$2"; shift 2 ;;
    --out)          OUT_DIR="$2"; shift 2 ;;
    --dry-run)      DRY_RUN=1; shift ;;
    --verbose)      VERBOSE=1; shift ;;
    --no-faststart) FASTSTART=0; shift ;;
    --no-summary)   SHOW_SUMMARY=0; shift ;;
    --fflog)        FFLOG="$2"; FFLOG_SET=1; shift 2 ;;
    -v)             FFLOG="$2"; FFLOG_SET=1; shift 2 ;; # alias
    --stats)        STATS=1; STATS_SET=1; shift ;;
    -h|--help)      print_help ;;
    *) echo "Unknown arg: $1"; echo "Use --help"; exit 1 ;;
  esac
done

# run ___  --verbose convenience unless user explicitly set fflog/stats:
if [[ $VERBOSE -eq 1 ]]; then
  [[ $FFLOG_SET -eq 0 ]] && FFLOG="info"
  [[ $STATS_SET -eq 0 ]] && STATS=1
fi

# _____________  pre-flight check ___________
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found"; exit 1; }
command -v awk    >/dev/null 2>&1 || { echo "awk not found"; exit 1; }
mkdir -p "$IN_DIR" "$OUT_DIR"

# ______ collect .mov/.mp4 recursively:
VIDEO_FILES=()
while IFS= read -r -d '' f; do
  VIDEO_FILES+=("$f")
done < <(find "$IN_DIR" -type f \( -iname "*.mov" -o -iname "*.mp4" \) -print0)

if [[ ${#VIDEO_FILES[@]} -eq 0 ]]; then
  echo "[⚠] No .mov/.mp4 files found in $IN_DIR"
  exit 1
fi

# ______ validate basic setup: 
[[ "$MODE" =~ ^(crf|bitrate)$ ]] || { echo "Invalid --mode: $MODE"; exit 1; }
[[ "$WIDTH" =~ ^[0-9]+$ ]] || { echo "Width must be integer"; exit 1; }
case "$FFLOG" in
  quiet|panic|fatal|error|warning|info|verbose|debug|trace) ;;
  *) echo "Invalid --fflog: $FFLOG"; exit 1 ;;
esac

# ______ compute speed factor + even width:
FACTOR="$(awk "BEGIN {printf \"%.6f\", 1.0/$SPEED}")"
WIDTH_EVEN=$(( WIDTH/2*2 ))

# ____ rate control:
if [[ "$MODE" == "crf" ]]; then
  RATE=(-crf "$CRF")
else
  RATE=(-b:v "$BITRATE")
fi

# ____ logging / progress args:
FF_LOG=(-loglevel "$FFLOG" -nostdin)
[[ $STATS -eq 1 ]] && FF_LOG+=(-stats)

# ___ faststart arg:
if [[ $FASTSTART -eq 1 ]]; then
  MOVFLAGS=(-movflags +faststart)
else
  MOVFLAGS=()
fi

trap 'echo; echo "[!] Interrupted"; exit 130' INT TERM

echo -e "\n=== Config ==="
echo "Input dir   : $IN_DIR"
echo "Output dir  : $OUT_DIR"
echo "Files found : ${#VIDEO_FILES[@]}"
echo "Speed       : ${SPEED}x (setpts=${FACTOR}*PTS)"
echo "Size        : $([[ $KEEP_SIZE -eq 1 ]] && echo 'preserve' || echo "width=$WIDTH_EVEN (height auto)")"
echo "Mode        : $MODE $([[ $MODE == crf ]] && echo "(CRF=$CRF)" || echo "(BR=$BITRATE)")"
echo "Preset      : $PRESET"
echo "Faststart   : $([[ $FASTSTART -eq 1 ]] && echo enabled || echo disabled)"
echo "FFmpeg log  : $FFLOG $([[ $STATS -eq 1 ]] && echo '(stats on)' || echo '')"
[[ $DRY_RUN -eq 1 ]] && echo "[DRY RUN] printing commands only"

# ________ Process ________ 
for in_file in "${VIDEO_FILES[@]}"; do
  base="$(basename "$in_file")"
  name="${base%.*}"
  out_file="$OUT_DIR/${name}_${SPEED}x.mp4"

  # ___ build video filter:
  if [[ "$KEEP_SIZE" -eq 1 ]]; then
    VF="setpts=${FACTOR}*PTS"
  else
    VF="setpts=${FACTOR}*PTS,scale=${WIDTH_EVEN}:-2"
  fi

  cmd=(ffmpeg -hide_banner "${FF_LOG[@]}" -y
       -i "$in_file"
       -filter:v "$VF"
       -c:v libx264 -preset "$PRESET" "${RATE[@]}"
       "${MOVFLAGS[@]}"
       -an
       "$out_file")

  echo -e "\n[INFO] $in_file"
  echo "[OUT ] → $out_file"

  if [[ $DRY_RUN -eq 1 ]]; then
    printf 'CMD  : '; printf '%q ' "${cmd[@]}"; echo
    continue
  fi

  "${cmd[@]}"
  if [[ -s "$out_file" ]]; then
    echo "[OK  ] Wrote: $out_file"
  else
    echo "[ERR ] Failed: $out_file"
  fi
done

if [[ $SHOW_SUMMARY -eq 1 ]]; then
  echo -e "\nDone! Outputs in: $OUT_DIR/"
  du -sh "$OUT_DIR"/*.mp4 2>/dev/null || true
fi


# _____________________________________________________________________________________________________________________________________________________________________
# Keep original size, show progress bar:                    [ ./mp4_media_converter_ffmpeg.sh --keep-size --fflog info --stats ]
# Chatty debug logs with progress:                          [ ./mp4_media_converter_ffmpeg.sh --fflog debug --stats ]
# Silent run (no progress, minimal logs):                   [ ./mp4_media_converter_ffmpeg.sh --fflog quiet --no-summary ]
# Convenience verbose (equivalent to --fflog info --stats): [ ./mp4_media_converter_ffmpeg.sh --keep-size --verbose ]
# Bitrate mode with custom width and preset, progress on:   [ ./mp4_media_converter_ffmpeg.sh --mode bitrate --bitrate 1200k --width 960 --preset slow --fflog info --stats] 
# _____________________________________________________________________________________________________________________________________________________________________