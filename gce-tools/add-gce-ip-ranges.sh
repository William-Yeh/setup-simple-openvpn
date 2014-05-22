#!/bin/bash

echo "# IP ranges for GCE"

./dig-gce-ip-ranges.pl | ./cidr-to-openvpn-route.pl \
    | sort \
    | perl -ne 'chomp; print "push \"route ", $_, "\"\n";'

