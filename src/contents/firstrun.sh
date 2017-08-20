#!/bin/bash
set -e
if ! [[ -z "$TIME_ZONE" ]]; then
    sed -i "s:TIME_ZONE = '.*':TIME_ZONE='$TIME_ZONE':" /opt/websafety/var/console/console/settings.py
fi
cd /opt/websafety/var/spool
mv adblock adblock.a && mv adblock.a adblock
mv adult adult.a && mv adult.a adult
mv categories categories.a && mv categories.a categories
mv categories_custom categories_custom.a && mv categories_custom.a categories_custom
mv privacy privacy.a && mv privacy.a privacy

# Generate SQUID Certificates
/usr/lib/squid/ssl_crtd -c -s /var/spool/squid_ssldb
