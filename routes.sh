#!/usr/bin/env bash
declare -A ROUTES

ROUTES["/"]="root"

response() {
  echo -e "HTTP/1.1 200 OK\r\nConnection: close\r\n\r$1"
}

root() {
  local verb=$1
  local body=$2
  eval "declare -A headers="${3#*=}
  response "yep yepa"
}


