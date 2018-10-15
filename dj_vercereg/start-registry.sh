#!/bin/bash
localsettemp=/registry/dj-vercereg/dj_vercereg/dj_vercereg/local_settings_template.py
localset=/registry/dj-vercereg/dj_vercereg/dj_vercereg/local_settings.py
port=8000

# Local settings workflow / initializer

if [[ -f $localset && ! -L $localset ]]; then
	echo "Using custom local_settings.py..."
else
	if [ ! -L $localset ]; then
		echo "Creating local_settings_template.py link......"
		ln -s $localsettemp $localset
	else	
		echo "Using local_settings_template.py as local_settings.py, if you want to use custom settings you should create a custom local_settings.py file. Using local_settings_template.py as is, is not safe."
	fi
fi

# Registry db initializations

echo 'Initializing.....'

./manage.py makemigrations
./manage.py migrate
./manage.py migrate --run-syncdb

# Create superuser from localsettings
username=`cat $localset | grep USER | awk -F ":" '{print $2}'`
username=`sed -n "s/^.*'\(.*\)'.*$/\1/ p" <<< ${username}`

password=`cat $localset | grep PASSWORD | awk -F ":" '{print $2}'`
password=`sed -n "s/^.*'\(.*\)'.*$/\1/ p" <<< ${password}`

email=$username'@example.com'

echo 'Creating super user.....'

echo "from django.contrib.auth.models import User; User.objects.create_superuser($username, $email, $password)" | python manage.py shell

echo 'Fixtures....'

./manage.py loaddata fixtures/def_group.json

echo 'Starting web server....'

./manage.py runserver 0.0.0.0:$port