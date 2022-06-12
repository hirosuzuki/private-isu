#!/bin/sh

exec ./app -bind "127.0.0.1:8080" 2>/tmp/app.err >/tmp/app.out
