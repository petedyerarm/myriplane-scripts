#!/bin/bash

# Parse command line
args_list="name:"
args_list="${args_list},verbose"

args=$(getopt -o+ho:x -l $args_list -n "$(basename "$0")" -- "$@")

eval set -- "$args"

while [ $# -gt 0 ]; do
    if [ -n "${opt_prev:-}" ]; then
        eval "$opt_prev=\$1"
        opt_prev=
        shift 1
        continue
    elif [ -n "${opt_append:-}" ]; then
        eval "$opt_append=\"\${$opt_append:-} \$1\""
        opt_append=
        shift 1
        continue
    fi
    case $1 in
    --name)
        opt_prev=INCUS_NAME
        ;;
    --verbose)
        _verbose="--verbose"
        ;;
    --)
        shift
        break 2
        ;;
    esac
    shift 1
done


if [ -z "${INCUS_NAME:-}" ]; then
  printf "error: missing parameter --name ContainerName\n" >&2
  exit 3
fi

if [ -n "${_verbose:-}" ]; then
    set -x
fi

# Lanch the instance

incus launch images:ubuntu/22.04 --profile default --profile capability-autostart --profile capability-disable-secureboot --vm -c limits.cpu=32 -c limits.memory=64GB -d root,size=40GB --target H93 "$INCUS_NAME"

echo "Waiting for VM to start"
sleep 5
while [[ $(incus info "${INCUS_NAME}" |grep "Processes:") == *"-1"* ]]; do
    echo -n "."
    sleep 2
done

# push some files over to the instance that will do the heavy lifting

# git-credentials:
incus file push "$HOME"/.git-credentials "$INCUS_NAME"/home/ubuntu/.git-credentials --gid 1000 --uid 1000
incus file push "$HOME"/.gitconfig "$INCUS_NAME"/home/ubuntu/.gitconfig --gid 1000 --uid 1000

# setup scripts
incus file push setup_1.sh "$INCUS_NAME"/home/ubuntu/setup_1.sh --gid 1000 --uid 1000
incus file push setup_2.sh "$INCUS_NAME"/home/ubuntu/setup_2.sh --gid 1000 --uid 1000

# Add tmux to make life easier.
incus exec "$INCUS_NAME" -- apt install -y tmux





