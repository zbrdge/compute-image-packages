#!/bin/sh

# disable IPv6
#  -- necessary?

# prevent the instance from remembering it's MAC address
#  -- necessary?

# set timezone to UTC:
# ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# use Google NTP servers only
# xbps-install -y ntp
# sed -i 's:^server:#server:g' /etc/ntp.conf
# echo 'server metadata.google.internal iburst' >> /etc/ntp.conf
# ln -sf /etc/sv/ntpd /var/service/

# use cURL to set the hostname at boot from the
# metadata server (and once an hour too ... why not?):
xbps-install -y curl

cat > google-hostname-manager <<EOF
#!/bin/sh
while true; do
/usr/bin/curl --silent --max-time 10 --connect-timeout 3 -H "Metadata-flavor:Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/hostname
sleep 1h
done
EOF

chmod +x google-hostname-manager
cp google-hostname-manager /usr/share/google

[ ! -d /etc/sv/google-hostname-manager ] && mkdir -v /etc/sv/google-hostname-manager

cat > /etc/sv/google-hostname-manager/run <<EOF
#!/bin/sh
[ -r conf ] && . ./conf
exec /usr/share/google/google-hostname-manager
EOF

chmod +x /etc/sv/google-hostname-manager/run
ln -sf /etc/sv/google-hostname-manager /var/service/
sv start google-hostname-manager
