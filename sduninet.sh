#!/bin/bash

wpa=/wpa_supplicant.conf
interface=/etc/network/interfaces

clear
echo
echo 'Nastavitev interneta brez certifikata za Študentske domove v Ljubljani za tiste,
ki jim ne gre v nos povezovanje z Network-Managerjem'
echo
echo 'Če ste kaj nastavljali wpa_supplicant za kakršnokoli zadevo,
jo dobite pod wpa_supplicant.conf.bak, v nasprotnem primeru, gremo dalje :)'
echo
if [ -f $wpa ]; then
    if [ ! -f ${wpa}.bak ]; then
        echo "$wpa še nima varnostne kopije, pritisni poljubno tipko, da jo ustvari."
        read -sn 1
        sudo cp $wpa ${wpa}.bak
        echo "$wpa varnostna kopija narejena!"
        echo
    fi
fi

echo "1.) Vaše uporabniško ime tipa: janez1@sd.uni-lj.si"
read username
echo
echo "2.) Vaše geslo"
read password

if [ -f $wpa ]; then
    sudo rm $wpa
fi

if [ ! -f $wpa ]; then
    sudo touch $wpa
fi
clear
echo "Če ste zgrešili uporabniško ime ali geslo prosim da ponovno zaženete skripto:"
echo
echo 'ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
eapol_version=1
ap_scan=0
fast_reauth=1
network={
key_mgmt=IEEE8021X
eapol_flags=0
eap=TTLS
anonymous_identity="anonymous@sd.uni-lj.si"
phase2="auth=PAP"
identity="'$username'"
password="'$password'"
}' | sudo tee -a $wpa

sudo chown root $wpa
sudo chmod 600 $wpa

echo
echo "Pritisni poljubno tipko za nadaljevanje..."
read -sn 1
clear
f_interface() {
    egrep -xq "^auto eth0|^iface eth0 inet dhcp|wpa-driver wired|wpa-conf /etc/wpa_supplicant.conf" $interface &>/dev/null
}

if f_interface; then
    echo 'Trenutne nastavitve '$interface':'
    echo
    cat $interface | egrep "^auto eth0|^iface eth0 inet dhcp|wpa-driver wired|wpa-conf /etc/wpa_supplicant.conf"
else
    echo
    echo ''$interface' še ni nastavljena!'
    echo
    if [[ ! f_interface || ! -f $interface ]]; then
        echo 'V '$interface' smo dodali naslednje:'
        echo
        echo 'auto eth0
        iface eth0 inet dhcp
        wpa-driver wired
        wpa-conf /etc/wpa_supplicant.conf' | sudo tee -a $interface
    fi
fi

echo
echo "Pritisni poljubno tipko za nadaljevanje..."
read -sn 1

echo
echo 'To bi moralo biti to, še "networking" restartamo pa bi moralo delovati :)
(v primeru da vam restartanje netowrkinga zariba sistem, reštartajte mašino :P,
ubuntu rad heca s takimi neumnostimi...)
večina sistemov: [$ sudo service networking restart]
ubuntu: reštartaj računalnik ali poskusi zgornje, če si pogumen :D'
echo
