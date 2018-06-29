
RESPONSE=""

init_response() {
  local status=$1
  local status_msg=$2
  RESPONSE="HTTP/1.1 $status $status_msg"
} 

add_header_to_response() {
  RESPONSE="${RESPONSE}\r\n$1"
}

add_body_to_response() {
  RESPONSE="${RESPONSE}\r\n\r\n$1"
}

reset_response() {
  RESPONSE=""
}

get_response() {
  echo "$RESPONSE"
}
