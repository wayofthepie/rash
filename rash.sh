#!/bin/bash
inception="$( cd "$(dirname "$0")" ; pwd -P )"/$(basename "${BASH_SOURCE[0]}")

declare -A HEADERS
BODY=""
VERB=""
ROUTE=""

while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -s|--serve)
    SERVE=true
    shift # past argument
    ;;
    -r|--routes)
    ROUTES_FILE="$2"
    shift
    shift
    ;;
  esac
done

[ $SERVE ] && {
  while true ; do ncat -l -p 1500 -m 1000 -k -c "$inception -r $ROUTES_FILE" ; done
  exit 0
}

source $ROUTES_FILE

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
    HEADERS[${key::-1}]=$value
  fi   
}

parse_body() {
  local length=$1
  while getchar char;
  do
    BODY+=$char
    size=`printf "%s" "$BODY" | wc -c`
    result=$(awk -v n1=$size -v n2=$length 'BEGIN{print (n1>=n2)?0:1}')
    if [ "$result" = 0 ]; then
      break
    fi
  done
}

parse_verb() {
  VERB=`echo "$1" | awk '{print $1}'`
  ROUTE=`echo "$1" | awk '{print $2}'` 
}

parse_request() {
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
      if [ -z $parsed_verb ]; then
        parse_verb "$line"
        parsed_verb=true 
      else 
        parse_header "$line"
      fi
    fi
    
    if isn "$char" && [ $newline = 2 ]; then
      parse_body "${HEADERS["Content-Length"]}" 
      break
    fi

    if isn "$char"; then
      line=""
    fi 

    prev_char=$char
  done <&0
}

parse_request

${ROUTES[$ROUTE]} $VERB $BODY "$(declare -p HEADERS)"

