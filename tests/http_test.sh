#!/usr/bin/env bats
load ../http

@test "should correctly init response" {
  # Arrange 
  status=200
  status_msg="OK"

  # Act
  init_response "$status" "$status_msg"

  # Assert
  r=`get_response`
  [ "$r" = "HTTP/1.1 $status $status_msg" ]
}

@test "should add header to response" {
  # Arrange
  header="Content-Length: 42"
  init_response "200" "OK"

  # Act 
  add_header_to_response "$header" 

  # Assert
  r=`get_response`
  [ "$r" = "HTTP/1.1 200 OK\r\n$header" ]
}

@test "should add body to response" {
  # Arrange
  body="stuff"
  init_response "200" "OK"

  # Act 
  add_body_to_response "$body" 

  # Assert
  r=`get_response`
  [ "$r" = "HTTP/1.1 200 OK\r\n\r\n$body" ]
}
