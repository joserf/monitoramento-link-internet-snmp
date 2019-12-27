#!/bin/bash -e
clear

if [ "$UID" -ne 0 ]; then
  echo "Por favor, execute como root"
  exit 1
fi

read -p 'Digite o ip do servidor autorizado para coletar os dados SNMP :' SNMP_IP
read -p 'COMMUNITY ex: public: ' COMMUNITY
read -p 'Digite o seu e-mail : ' EMAIL
read -p 'Digite o local ou identificacao desse servidor :' LOCAL

clear

echo IP autorizado: $SNMP_IP
echo COMMUNITY: $COMMUNITY
echo E-mail: $EMAIL 
echo Local: $LOCAL && sleep 10

if [ -x /usr/bin/apt-get ]; then
  # Instala os pacotes 
  apt-get update && \
  apt-get purge snmpd -y && \
  apt-get install snmpd -y && \
  # parando SNMP 
  /etc/init.d/snmpd stop \
  # BKP configuracoes
  cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.bkp
  # efetua as configuracoes
  sed -i "s/agentAddress  udp:127.0.0.1:161/agentAddress  udp:0.0.0.0:161/" /etc/snmp/snmpd.conf
  sed -i '47i\view   all         included   .1                80' /etc/snmp/snmpd.conf 
  sed -i "s/rocommunity public  default    -V systemonly/#rocommunity public  default    -V systemonly/" /etc/snmp/snmpd.conf
  sed -i "58i\rocommunity $COMMUNITY  $SNMP_IP" /etc/snmp/snmpd.conf
  sed -i "s/sysContact     Me <me@example.org>/sysContact     <$EMAIL>/" /etc/snmp/snmpd.conf
  sed -i "s/sysLocation    Sitting on the Dock of the Bay/sysLocation    $LOCAL/" /etc/snmp/snmpd.conf
  #inicia o SNMP
  /etc/init.d/snmpd start && /etc/init.d/snmpd status

  exit 0
fi
