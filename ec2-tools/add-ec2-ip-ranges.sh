#!/bin/bash

echo "# IP ranges for EC2"

#./dig-gce-ip-ranges.pl | ./cidr-to-openvpn-route.pl \
#    | sort \
#    | perl -ne 'chomp; print "push \"route ", $_, "\"\n";'

IP_RANGE_DOC='https://forums.aws.amazon.com/ann.jspa?annID=1701'


lynx -dump -nolist -width=1024  $IP_RANGE_DOC \
    | ./refresh.py
