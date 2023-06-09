#!/bin/bash
echo "!!!conda environment must be active!!!"
gunicorn -w 1 -b 0.0.0.0:8000 --timeout 360 app:app