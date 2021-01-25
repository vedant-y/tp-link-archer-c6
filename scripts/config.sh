#!/bin/sh

usage() {
  echo "Utility to encode or decode TP-Link Archer A6/C6 configuration file."
  echo ""
  echo "Usage: $(basename $0) [enc|dec] -i config.bin -o config.xml [-r config.bin]"
  echo ""
  echo "Modes:"
  echo " enc, encode     Pack and encrypt config"
  echo " dec, decode     Decrypt and unpack config"
  echo ""
  echo "Options:"
  echo " -i, --input     Path to input file"
  echo " -o, --output    Path to output file"
  echo " -r, --refer     Path to reference file"
  echo "                 Required only for encoding, optional, but recommended"
  echo ""
  exit 1
}

password="0123456789abcdef"

encrypt() {
  lua -e "require('luarsa').aes_enc_file('$1', '$2', 1, '$password')"
}

decrypt() {
  lua -e "require('luarsa').aes_dec_file('$1', '$2', 1, '$password')" > /dev/null
}

pack() {
  if [ -f "$input" ]; then
    # Prepare Workspace
    workspace="$(mktemp -d)"
    mkdir -p "$workspace/dir" "$workspace/tmp"
    cp "$input" "$workspace/tmp/user-config.xml"

    # Refer Config
    if [ -f "$refer" ]; then
      decrypt "$refer" "$workspace/refer.tar"
      tar -xf "$workspace/refer.tar" -C "$workspace/dir"

    else
      touch "$workspace/dir/ori-backup-certificate.bin"

    fi
    
    # Create Tarball
    tar -czf "$workspace/dir/ori-backup-user-config.bin" -C "$workspace" "tmp/user-config.xml"
    tar -cf "$workspace/config.tar" -C "$workspace/dir" .
    
    # Encrypt Config
    encrypt "$workspace/config.tar" "$output"

    # Clear Workspace
    rm -rf "$workspace"

  else
    echo "EACCES: $input"

  fi
}

unpack() {
  if [ -f "$input" ]; then
    # Prepare Workspace
    workspace="$(mktemp -d)"
    mkdir -p "$workspace/dir" "$workspace/tmp"
    
    # Decrypt Config
    decrypt "$input" "$workspace/config.tar"
    
    # Extract Tarball
    tar -xf "$workspace/config.tar" -C "$workspace/dir"
    tar -xzf "$workspace/dir/ori-backup-user-config.bin" -C "$workspace"
    
    # Clear Workspace
    mv "$workspace/tmp/user-config.xml" "$output"
    rm -rf "$workspace"

  else
    echo "EACCES: $input"

  fi
}

# Parse Argument
while [ "$1" != "" ]; do
  case "$1" in
    enc|encode)
      mode="enc"
      ;;
    dec|decode)
      mode="dec"
      ;;
    -i|--input)
      [ "$2" != "" ] && input="$2" || usage
      shift
      ;;
    -o|--output)
      [ "$2" != "" ] && output="$2" || usage
      shift
      ;;
    -r|--refer)
      [ "$2" != "" ] && refer="$2" || usage
      shift
      ;;
    *)
      usage
  esac
  shift
done

# Main
case "$mode" in
  enc)
    pack
    ;;
  dec)
    unpack
    ;;
  *)
    usage
esac
