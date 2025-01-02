#!/bin/bash

docker build -t yeak/zimbraimage-rl9 .

docker build -t yeak/zimbraimage-rl9:10.1.0 . -f Dockerfile-10.1.0
docker build -t yeak/zimbraimage-rl9:10.1.1 . -f Dockerfile-10.1.1
