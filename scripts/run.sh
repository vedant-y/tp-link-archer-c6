#!/bin/sh

# Superuser Access
if [ "$(id -u)" != "0" ]; then
  sudo "$0" "$@"
  exit 1
fi

root_fs="container/root.squashfs"

usage() {
  echo "Usage: $(basename $0) [-f container.squashfs]"
  echo ""
  echo "Options:"
  echo " -f, --file    Path to squashfs container"
  echo ""
  exit 1
}

# Parse Argument
while [ "$1" != "" ]; do
  case "$1" in
    -f|--file)
      [ "$2" != "" ] && root_fs="$2" || usage
      shift
      ;;
    *)
      usage
  esac
  shift
done

# Main
if [ -f "$root_fs" ]; then
  # Prepare Workspace
  workspace="$(mktemp -d -p /mnt)"
  mount -t squashfs -o loop "$root_fs" "$workspace"
  mount -t tmpfs -o size=8M tmpfs "$workspace/tmp"

  # Chroot File System
  echo "Container @ $workspace"
  chroot "$workspace" /bin/sh
  echo "\n"

  # Clear Workspace
  umount -l "$workspace/tmp" "$workspace"
  rm -rf "$workspace"

else
  echo "EACCES: $root_fs"
  
fi
