#!/bin/bash

function print_help_and_exit() {
  {
    echo "$0 [-d|--download-dir PATH]: "
    echo "    PATH: directory that holds downloaded tarballs. If empty or "
    echo "          unspecified, a temp directory will be created and deleted "
    echo "          before exit."
  } >&2
  exit 1
}

OPTS=$(getopt -o d: --long download-dir: -n "$(basename "$0")" -- "$@") \
  || print_help_and_exit
eval set -- "${OPTS}"

download_dir=

while true; do
  case "$1" in
    -d|--download-dir) download_dir=$2; shift 2 ;;
    --) shift; break ;;
    *) echo "Internal error" >&2; print_help_and_exit;;
  esac
done

if (( $# > 0 )); then
  echo "Unrecognized arguments $@" >&2
  print_help_and_exit
fi

if ! mkdir -pv /opt/krte || ! touch /opt/krte/.dummy; then
  echo "Please create directory /opt/krte and make sure it is writable to" \
       "current user" >&2
  exit 1
fi
rm -f /opt/krte/.dummy

if [[ "${download_dir}" == "" ]]; then
  download_dir=$(mktemp -d)
  function clear_download_dir() {
    rm -rf "${download_dir}"
  }
  trap clear_download_dir EXIT
fi

cd "${download_dir}"

function download() {
  if ! wget --input-file=- --continue --directory-prefix=. \
       --progress=dot:giga << "EOF"
https://github.com/likan999/KRTE/releases/download/v1.0/toolchain.tar.xz
https://github.com/likan999/KRTE/releases/download/v1.0/libs.tar.xz
EOF
  then
    echo "Failed to download, exit" >&2
    exit 1
  fi
}

function verify() {
  md5sum -c - << "EOF"
18fa38806f7613d007ef726ca3e33570  toolchain.tar.xz
50feaf13ec88b20986b8bfd3e25422d9  libs.tar.xz
EOF
}

download
if ! verify; then
  echo "Checksum doesn't match, retry" >&2
  rm -f toolchain.tar.xz libs.tar.xz
  download
  if !verify; then
    echo "Checksum doesn't match, exit" >&2
    exit 1
  fi
fi

cd /
tar xJvf "${download_dir}/toolchain.tar.xz" /opt/krte/toolchain
tar xJvf "${download_dir}/libs.tar.xz" /opt/krte/libs

cd
tar xJvf "${download_dir}/toolchain.tar.xz" .krte.bashrc .krte/
tar xJvf "${download_dir}/libs.tar.xz" .krte/
