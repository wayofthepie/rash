#!/bin/bash
inception="$( cd "$(dirname "$0")" ; pwd -P )"/$(basename "${BASH_SOURCE[0]}")

declare -A headers
body=""

[ "$1" == "serve" ] && {
  while true ; do ncat -l -p 1500 --exec "/bin/bash -c $inception" ; done
  exit 0
}

getchar() {
  IFS= read -n1 -d '' "$@"
}

isn() {
  [ "$1" = $'\n' ] && return 0 || return 1
}

isr() {
  [ "$1" = $'\r' ] && return 0 || return 1
}

parse_header() {
  key=`echo "$1" | egrep ".*:.*" | awk '{print $1}'`
  value=`echo "$1" | egrep ".*:.*" | awk '{for (i=2; i<=NF; i++) print $i}'`
  if [ ! -z "$key" ]; then
    headers[${key::-1}]=$value
  fi   
}

parse_body() {
  local length=$1
  while getchar char;
  do
    body+=$char
    size=`printf "%s" "$body" | wc -c`
    result=$(awk -v n1=$size -v n2=$length 'BEGIN{print (n1>=n2)?0:1}')
    if [ "$result" = 0 ]; then
      break
    fi
  done
}

line=""
while getchar char;
do
  if ! isn "$char" || ! isr "$char"; then
    line+=$char
  fi
  
  if isn "$char"; then
    let "newline++"
  else
    if ! isr "$char"; then
      newline=0
    fi
  fi

  if [ -n "$line" ] && isn "$char"; then
    parse_header "$line"
  fi
  
  if isn "$char" && [ $newline = 2 ]; then
    parse_body "${headers["Content-Length"]}" 
    break
  fi

  if isn "$char"; then
    line=""
  fi 

  prev_char=$char
done <&0

for i in "${!headers[@]}"
do
  echo "key  : $i"
  echo "value: ${headers[$i]}"
done
echo -e "\n"
echo -e "Body:\n$body"

