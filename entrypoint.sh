#!/bin/bash
set -eu
set -o pipefail

select_init()
{
  if [ $$ -eq 1 ]; then
    if egrep "^/sbin/docker-init" /proc/1/cmdline >/dev/null 2>&1; then
      echo ""
    else
      echo "tini"
    fi
  else
    echo ""
  fi
}


if [ $(id -u) -eq $(id -u root) ]; then
  # root
  SET_GID=${SET_GID:-$(stat -c "%g" .)}
  SET_UID=${SET_UID:-$(stat -c "%u" .)}
  if [ $(id -u root) -eq $SET_UID -a $(id -g root) -eq $SET_GID ]; then
    eval exec $(select_init) -- "$@"
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
    eval exec $(select_init) -- setpriv --reuid=$SET_UID --regid=$SET_GID --groups $SET_GID "$@"
  fi
else
  # not root
  eval exec $(select_init) -- "$@"
fi

