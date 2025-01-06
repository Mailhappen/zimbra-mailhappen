#!/bin/bash

docker build -t yeak/zimbraimage:latest .
docker build -t yeak/zimbraimage:10.1.4 .

# archive - still needed for upgrade testing
docker build -t yeak/zimbraimage:10.1.0 . -f Dockerfile-10.1.0
docker build -t yeak/zimbraimage:10.1.1 . -f Dockerfile-10.1.1
