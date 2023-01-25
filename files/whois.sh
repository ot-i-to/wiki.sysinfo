#!/bin/bash

#IPSET=/usr/sbin/ipset
IPSET=/sbin/ipset
IPNEW=/etc/RU/ip.new
IPSETADD=/etc/RU/ipset.add
IPCALC=/etc/RU/ipcalc.pl
COUNT=0
MASK=" "
COUNTRY=" "

funFCOUNT() {
    FCOUNT=/etc/RU/$(date "+%Y-%m-%d")-count.whois
    if [[ ! -f $FCOUNT ]]; then
	echo 0 > $FCOUNT
    fi
    if [[ -f $FCOUNT ]]; then
	echo $(($(cat $FCOUNT) + 1)) > $FCOUNT
    else
	echo 1 > $FCOUNT
    fi
    COUNT=$(cat $FCOUNT)
    #rm -f /etc/RU/$(date +%Y-%m-%d -d '1 day ago')-count.whois
}

funWHOIS() {
	whois $IP > /tmp/$IP.whois
	COUNTRY=$(cat /tmp/$IP.whois | grep -iE "^Country:" | sed s/'[cC]ountry:'// | sed s/' '//g | sed -n '$p')
	MASK=$(cat /tmp/$IP.whois | grep -iE "^CIDR:|^route:" | sed s/'^CIDR:'// | sed s/'^[rR]oute:'// | sed s/' '//g | sed -n '$p')
	if [[ -z $MASK ]]; then
	    tmpMASK=$(cat /tmp/$IP.whois | grep -iE "^inetnum:" | sed s/'^[iI]netnum:'// | sed s/' '//g | sed -n '$p')
	    #MASK=$($IPCALC $tmpMASK | grep '/')
	    MASK=$($IPCALC $tmpMASK | grep -i 'Network:' | awk '{ print $2}')
	    if [[ -z $MASK ]]; then
		MASK=$($IPCALC $tmpMASK | grep -i '/')
		if [[ -z $MASK ]]; then
		    MASK="NO_INFO"
		fi
	    fi
	fi
	rm -f /tmp/$IP.whois
}

funIPSET() {
	if [[ $COUNTRY = 'RU' ]] || [[ $COUNTRY = 'ru' ]] || [[ $COUNTRY = 'Ru' ]]; then
	    if [[ $($IPSET list russia_run | grep -c $MASK) = 0 ]]; then
		if $IPSET -q add russia_run $MASK; then
			echo "$(date +'%x %T ') [$COUNT] ADD Russian MASK: $MASK" >> $IPSETADD
		fi
	    fi
	fi
}

#################### START #############################################################################################################################
while read line; 
do
    #IP=$(echo $line | awk '{ print $10}' | sort | uniq | sed 's/SRC=//' | sed s/' '//g )
    IP=$(echo $line | awk '{ print $11}' | sort | uniq | sed 's/SRC=//' | sed s/' '//g )
    if [[ -f $IPNEW ]]; then
	if [[ $(grep -c $IP $IPNEW) = 0 ]]; then
	    funFCOUNT
	    if [[ $COUNT < 901 ]]; then
		funWHOIS
		echo "$(date +'%x %T ') [$COUNT] New No Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK" >> $IPNEW
		funIPSET
	    else
		echo "$(date +'%x %T ') [$COUNT] New No ADD Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK --> limit search whois info !" >> $IPNEW
	    fi
	fi
    else
	funFCOUNT
	if [[ $COUNT < 901 ]]; then
	    funWHOIS
	    echo "$(date +'%x %T ') [$COUNT] New No Russian IP: $IP COUNTRY: $COUNTRY MASK: $MASK" >> $IPNEW
	    funIPSET
	fi
    fi
done

