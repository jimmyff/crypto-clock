#!/bin/sh
# Requires Alpine Linux to be installed
# See: https://github.com/schuhumi/alpine_kindle_kual
/usr/bin/ds.sh

if [ -f /mnt/us/alpine.sh ] && [ -f /etc/upstart/alpine.conf ] && [ -f /mnt/us/alpine.ext3 ] ; then
	start alpine
else
	fbink -pmh -y -5 "Error: Required files missing. Deploy Alpine first!"
fi
