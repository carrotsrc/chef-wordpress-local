#!/bin/bash
AUTOCONFIG=0

if [ "${1}" == "" ]; then
	echo "Usage:"
	echo "remwp.sh USERNAME VERSION [AUTOCONFIG]"
	exit
fi
if [ "${1}" == "-h" ]; then
	echo "Usage:"
	echo "addnode.sh USERNAME VERSION [AUTOCONFIG]"
	exit
fi

echo "{\"wp\":{\"sub\":\"${1}\"}}" |  sudo chef-client --local-mode --runlist 'recipe[wordpress::addinstall]' -j /dev/stdin
