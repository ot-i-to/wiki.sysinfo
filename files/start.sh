#!/bin/bash

#pgrep tail -x || (tail -F /var/log/messages | grep BAD_SIP_No_Russia-IPSET | /etc/RU/whois.sh &)
pgrep tail -x || (tail -F /var/log/syslog | grep BAD_SIP_No_Russia-IPSET | /etc/RU/whois.sh &)

