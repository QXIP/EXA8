#!/bin/bash

cd /usr/src
cd server
cd web

./manage.py runserver "0.0.0.0:80"
