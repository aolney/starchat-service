#!/bin/bash
now=$(date +"%T") 
echo "Current time : $now"
echo "!!! if service doesn't stand up in five minutes, check disk consumption and increase gunicorn timeout if disk is being used up !!!"
docker run -p 8000:8000 --rm --gpus all --runtime=nvidia starchat-service:1.0
