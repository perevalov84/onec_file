#!/bin/bash
WEBINST="$(find /opt -name webinst -type f 2>/dev/null | tail -n-1)"
WSDIR=/var/www

copy_nethasp () {
if [[ $NH_SERVER_ADDR =~ [0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3} ]]; then
  sed "s/NH_SERVER_ADDR.*/NH_SERVER_ADDR=$NH_SERVER_ADDR/g" /opt/nethasp.ini > /opt/1cv8/conf/nethasp.ini
fi
}

copy_nethasp 

# mkdir -p /infobases
while read f 
do
	BNAME="$(echo $f | awk -F'/' '{print $NF}')"
	BPATH=$f 
	echo "$WEBINST -publish -apache24 -wsdir $BNAME -dir $WSDIR$BNAME -connstr "File=\"$BPATH\"\;" -confpath /etc/apache2/apache2.conf"
	$WEBINST -publish -apache24 -wsdir $BNAME -dir $WSDIR$BNAME -connstr "File=\"$BPATH\";" -confpath /etc/apache2/apache2.conf
done <<< "$( find /infobases/ -maxdepth 1 -type d | awk '{print $NF}' )"

apache2ctl -D FOREGROUND
