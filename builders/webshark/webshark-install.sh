#!/bin/bash

apt-get update && apt-get install -y \
	git curl sudo

# curl -s https://packagecloud.io/install/repositories/qxip/cubro-pub/script.deb.sh | sudo bash

apt-get update && apt-get install -y \
	python3-django libglib2.0-0

ln -s /scripts/sharkd.tar.gz /sharkd.tar.gz

mkdir -p /caps

cd /usr/src
git clone https://bitbucket.org/jwzawadzki/webshark

mkdir server
cd server

django-admin startproject web && \
    chmod +x web/manage.py

cd web
cp -r /usr/src/webshark/web ./

./manage.py startapp webshark

mkdir -p ./webshark/static/webshark/
cp -r ./web/* ./webshark/static/webshark/

echo "INSTALLED_APPS += ('webshark',)" >> web/settings.py && \
    echo "SHARKD_CAP_DIR = '/caps/'" >> web/settings.py && \
    echo "ALLOWED_HOSTS = ['*']" >> web/settings.py && \
    echo "from django.conf.urls import include" >> web/urls.py && \
    echo "urlpatterns += [ url(r'^webshark/', include('webshark.urls')), ]" >> web/urls.py

cp sharkd_cli.py web-server/django/urls.py web-server/django/views.py web-server/django/models.py web-server/django/forms.py webshark/

./manage.py makemigrations
./manage.py migrate

