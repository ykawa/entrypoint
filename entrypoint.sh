#!/bin/bash
set -eu
set -o pipefail

init_wrapper()
{
  if egrep "^/sbin/docker-init" /proc/1/cmdline >/dev/null 2>&1; then
    # run with --init
    exec "$@"
  else
    # run without --init
    exec /usr/bin/tini -- "$@"
  fi
}


[ -e .env ] && . .env

if [ $(id -u) -eq $(id -u root) ]; then
  # root
  SET_GID=${SET_GID:-$(stat -c "%g" .)}
  SET_UID=${SET_UID:-$(stat -c "%u" .)}
  if [ $(id -u root) -eq $SET_UID -a $(id -g root) -eq $SET_GID ]; then
    init_wrapper "$@"
  else
    # Change to the owner of the current directory.
    if [[ -n ${HOME:+$HOME} ]]; then
      if [ $(getent passwd root | cut -d: -f6) = "$HOME" ]; then
        if getent passwd $SET_UID >/dev/null 2>&1; then
          HOME=$(getent passwd $SET_UID | cut -d: -f6)
        else
          # To make it the same as su-exec, change HOME=/.
          HOME=$PWD
        fi
      fi
    fi
    init_wrapper setpriv --reuid=$SET_UID --regid=$SET_GID --groups $SET_GID "$@"
  fi
else
  # not root
  init_wrapper "$@"
fi

