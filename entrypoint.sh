#!/bin/bash
set -eu
set -o pipefail

init_wrapper()
{
  if egrep "^/sbin/docker-init" /proc/1/cmdline >/dev/null 2>&1; then
    exec "$@"
  else
    exec /usr/bin/tini -- "$@"
  fi
}

[ -e .env ] && . .env

if [ $(id -u) -eq $(id -u root) ]; then
  #------------------------------------------------------------
  # SET_GIDの指定が無い場合はカレントディレクトリの所有グループ
  # SET_UIDの指定が無い場合はカレントディレクトリの所有ユーザー
  # https://zenn.dev/anyakichi/articles/73765814e57cba
  #------------------------------------------------------------
  SET_GID=${SET_GID:-$(stat -c "%g" .)}
  SET_UID=${SET_UID:-$(stat -c "%u" .)}
  if [ $(id -u root) -eq $SET_UID -a $(id -g root) -eq $SET_GID ]; then
    # rootだったときはそのまま実行する
    init_wrapper "$@"
  else
    if [[ -n ${HOME:+$HOME} ]]; then
      if [ $(getent passwd root | cut -d: -f6) = "$HOME" ]; then
        if getent passwd $SET_UID >/dev/null 2>&1; then
          HOME=$(getent passwd $SET_UID | cut -d: -f6)
        else
          # su-execと同じにするなら HOME=/ にする
          HOME=$PWD
        fi
      fi
    fi
    init_wrapper setpriv --reuid=$SET_UID --regid=$SET_GID --groups $SET_GID "$@"
  fi
else
  # 一般ユーザー指定(-u)時はそのままexec
  init_wrapper "$@"
fi

