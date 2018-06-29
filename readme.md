# Rash
A bash http server.

# Running
To launch the server just run:

```
$ ./rash.sh serve
```

And now curl it:
```
$ curl -i  -XPOST -d "Woohooo" localhost:1500 
key  : User-Agent
value: curl/7.58.0
key  : Content-Length
value: 7
key  : Host
value: localhost:1500
key  : Accept
value: */*
key  : Content-Type
value: application/x-www-form-urlencoded


Body:
Woohooo
```
