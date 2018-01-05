#!/bin/sh

# BEGIN VARIABLES
VERBOSE=0
BUILDMODE=0
CLEANMODE=0
GETMODE=0

PREFIX="$HOME/store/prefix"
TARGET=""
TMPDIR="/tmp/get"
mkdir -p "$TMPDIR"

# Pretty Formatting Codes.
LOGBIN=/bin/echo
ERRORFMT="\e[1m\e[31m"
WARNFMT="\e[1m\e[33m"
INFOFMT="\e[1m\e[97m"
RESETFMT="\e[0m"
# END VARIABLES

err() {
  ${LOGBIN} -e "${ERRORFMT}${1}${RESETFMT}" 1>&2
}

warn() {
  if [ ${VERBOSE:-0} -gt 0 ]; then
    ${LOGBIN} -e "${WARNFMT}${1}${RESETFMT}" 1>&2
  fi
}

info() {
  if [ ${VERBOSE:-0} -gt 1 ]; then
    ${LOGBIN} -e "${INFOFMT}${1}${RESETFMT}"
  fi
}

error_option() {
  err "$1: -$OPTARG"
  echo
  usage
  exit 1
}

missing_argument() {
  err "Missing Required Argument: $1"
  echo
  usage
  exit 1
}

abspwd() {
  cd "$(dirname "$(realpath "${0}")")" && pwd -P
}

usage() {
  echo "Usage: get.sh [OPTIONS] FORMULA"
  echo
  echo "Repository of shell-based install instructions."
  echo "Build projects from source easily and repeatably."
  if [ $# -gt 0 ]; then
    echo
    echo "E.g."
    echo "\$ get.sh -cgb git"
  fi
  echo
  echo "Options:"
  echo "  -b, --build            Build the provided formula."
  echo "  -c, --clean            Clean the provided formula."
  echo "  -g, --get              Get the provided formula."
  echo "  -h, --help             Print usage"
  echo "  -v, --verbose          Raise the verbosity for each flag present."
  exit 0
}

parse_option() {
  case "$1" in
    b|build) BUILDMODE=1 ;;
    c|clean) CLEANMODE=1 ;;
    g|get) GETMODE=1 ;;
    h|help) usage "verbose" ;;
    v|verbose) VERBOSE=$((VERBOSE + 1)) ;;
    \?) error_option "Invalid Option" ;;
    :) error_option "Missing Option" ;;
  esac
}

while getopts ":bcghv-:" opt; do
  # Normalize the long options.
  case "${opt}" in
    -)
      opt="${OPTARG}"
      OPTARG="$(eval echo "\$${OPTIND}")"
      ;;
  esac
  parse_option "${opt}"
done

shift $((OPTIND - 1))

# BEGIN IMPLICIT ARGUMENT PARSING
FORMULA="$1"
if [ -z "$FORMULA" ]; then
  missing_argument "FORMULA"
elif [ "$FORMULA" = "." ]; then
  FORMULA="$(abspwd)/formula/templates/git"
  SRC="." . "${FORMULA}"
  build
  exit 0
elif [ -f "$(abspwd)/formula/$FORMULA" ]; then
  FORMULA="$(abspwd)/formula/$FORMULA"
elif [ ! -f "$FORMULA" ]; then
  err "Formula File '$FORMULA' does not exist."
  exit 1
fi
shift

if [ ! $# -eq 0 ]; then
  warn "Truncating Extra Arguments: '$*'"
fi
# END IMPLICIT ARGUMENT PARSING

OLD_PWD="$PWD"
cd "$(dirname "$FORMULA")"
ret() {
  cd "$OLD_PWD"
  unset OLD_PWD
}
trap ret 0 2

FORMULA="$(basename "${FORMULA}")"
TARGET="$PREFIX/opt/${FORMULA}"
. "./$FORMULA"

[ "$CLEANMODE" -eq 1 ] && \
  cd "$TARGET" && clean && cd "$OLD_PWD" && rm -rf "$TARGET"

[ "$GETMODE" -eq 1 ] && \
  mkdir -p "$TARGET" && cd "$TARGET" && get

[ "$BUILDMODE" -eq 1 ] && \
  cd "$TARGET" && build
