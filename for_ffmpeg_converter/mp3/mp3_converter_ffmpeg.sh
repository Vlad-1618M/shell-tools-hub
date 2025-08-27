#!/usr/bin/env bash
set -euo pipefail

#                       === WMA/VMA to MP3 Batch Converter: ===
#     _____________________________________________________________________________________
#     macOS/Linux shell script for converting .wma and .vma audio files into .mp3 format:
#     ok with Unicode filenames:
#     handles spaces in paths:
#     avoids overwriting existing conversions:
#     _____________________________________________________________________________________
# ___ Batch conversion of .wma and .vma files to .mp3
# ___ Automatically creates files_in and files_out directories if missing:
# ___ Uses null-delimited loops to handle filenames with spaces or special chars:
# ___ Skips existing .mp3 files to avoid redundant work:
# ___ Gets good to high quality conversion == Bitrate: 192 kbps:
# ___                                      == Sample rate: 44.1 kHz:
# ___                                      == libmp3lame encoder:
#     _____________________________________________________________________________________
# ___ keeps metadata during conversion: just in case:
# ___ Supports macOS / Linux:
#     _____________________________________________________________________________________
# ___ Requirements:
# ___ FFmpeg ≥ 4.0:
# ___ install check: ________________________________
#     brew install ffmpeg
#     sudo apt update && sudo apt install ffmpeg -y
#     sudo dnf install ffmpeg
#     _____________________________________________________________________________________

yellow="\033[1;33m"
green="\033[1;32m"
white="\033[1;97m"
blue="\033[1;34m"
cyan="\033[1;36m"
pink="\033[1;35m"
red="\033[1;31m"
off="\033[0m"

# ----------------------- config (defaults; override args) -----------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR="$SCRIPT_DIR/files_in"
OUTPUT_DIR="$SCRIPT_DIR/files_out"

BITRATE="192k"
SAMPLE_RATE="44100"
LOGLEVEL="error"     # ffmpeg loglevel: quiet|panic|fatal|error|warning|info|verbose|debug|trace
OVERWRITE=0          # 0 = skip existing (default), 1 = overwrite
JOBS=""              # empty -> auto-detect cores

# ----------------------- helpers -----------------------
usage() {
  cat <<'EOF'
WMA/VMA → MP3 Batch Converter
Usage:
  mp3_converter_ffmpeg.sh [ args ]

Options:
  -h, --help                 Show this help and exit
  -b, --bitrate <kbps>       MP3 bitrate (default: 192k), e.g. 320k
  -r, --rate <hz>            Sample rate (default: 44100), e.g. 48000
      --in <dir>             Input directory (default: ./files_in)
      --out <dir>            Output directory (default: ./files_out)
  -j, --jobs <N>             Parallel jobs (default: auto = CPU cores)
      --overwrite            Overwrite existing .mp3 (default: skip)
  -q, --quiet                Set ffmpeg loglevel=warning
  -v, --verbose              Set ffmpeg loglevel=info

Examples:
  ./mp3_converter_ffmpeg.sh
  ./mp3_converter_ffmpeg.sh -b 320k -r 48000 -j 4
  ./mp3_converter_ffmpeg.sh --in ~/music/wma --out ~/music/mp3 --overwrite
  ./mp3_converter_ffmpeg.sh -j 4
                            -j/--jobs = degree of parallelism = how many conversions run side-by-side:
EOF
}

detect_cores() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    sysctl -n hw.ncpu
  else
    getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2
  fi
}

# ----------------------- parse args -----------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -b|--bitrate) BITRATE="${2:?}"; shift 2 ;;
    -r|--rate|--sample-rate) SAMPLE_RATE="${2:?}"; shift 2 ;;
    --in) INPUT_DIR="${2:?}"; shift 2 ;;
    --out) OUTPUT_DIR="${2:?}"; shift 2 ;;
    -j|--jobs) JOBS="${2:?}"; shift 2 ;;
    --overwrite) OVERWRITE=1; shift ;;
    -q|--quiet) LOGLEVEL="warning"; shift ;;
    -v|--verbose) LOGLEVEL="info"; shift ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
done

# ____ ffmpeg exist check:
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found"; exit 1; }

# ____ input dir exists check | create if not | exit call with instructions:
if [[ ! -d "$INPUT_DIR" ]]; then
  mkdir -p "$INPUT_DIR"
  echo -e "\n${cyan}New:\t${white}--> ${green}$(basename $INPUT_DIR) ${off}dir created:\n${yellow}Path:\t${white}--> ${pink}$INPUT_DIR"${off}
  echo -e "\n${green}cp ${off}or move ${red}[${yellow} .wma${off} / ${green}.vma ${red}] ${off}files to ${cyan}$(basename "$INPUT_DIR")${off}:\nthen re-run ${green}$(basename $0)${off} script when ready:"
  exit 0
fi

# ____ files exist check:
if ! find "$INPUT_DIR" -maxdepth 1 -type f \( -iname '*.wma' -o -iname '*.vma' \) -print -quit | grep -q .; then
  echo -e "\n${red}No${off}:\t${white}--> ${yellow}.wma${off}/${yellow}.vma ${off}files found in ${green}$INPUT_DIR${off}"
  ls -asl -R "$INPUT_DIR"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Input : $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo

# ----------------------- Parallel conversion -----------------------
# ____ default jobs = number of CPU cores | if not explicitly set:
if [[ -z "$JOBS" ]]; then
  JOBS="$(detect_cores)"
fi

export OUTPUT_DIR BITRATE SAMPLE_RATE LOGLEVEL OVERWRITE

# ____  xargs -P for parallelism | BSD + GNU supported:
find "$INPUT_DIR" -maxdepth 1 -type f \( -iname '*.wma' -o -iname '*.vma' \) -print0 \
| xargs -0 -I{} -P "$JOBS" bash -c '
  set -euo pipefail
  src="$1"
  base="$(basename "$src")"
  name="${base%.*}"
  dst="$OUTPUT_DIR/$name.mp3"

  # ____ exist/readable checks:
  if [[ -e "$dst" && "${OVERWRITE}" -eq 0 ]]; then
    echo "Exists, skipping: $dst"
    exit 0
  fi
  if [[ ! -r "$src" ]]; then
    printf "Not readable: %q\n" "$src"F
    exit 0
  fi
  printf " [ 🎧 ] Converting: %q → %q\n" "$base" "$(basename "$dst")"

  # ____ ffmpeg flags: |  -y (overwrite) only if requested; otherwise -n to avoid clobbering:
  ow_flag="-n"
  if [[ "${OVERWRITE}" -eq 1 ]]; then
    ow_flag="-y"
  fi

  ffmpeg -hide_banner -loglevel "$LOGLEVEL" "$ow_flag" \
    -fflags +genpts \
    -i "$src" -vn \
    -af aresample=async=1:first_pts=0 \
    -c:a libmp3lame -b:a "$BITRATE" -ar "$SAMPLE_RATE" \
    -map_metadata 0 \
    "$dst"

  printf "Wrote: %q\n" "$dst"
' _ "{}"

echo ______________________________________________________________________
echo "Done:"
