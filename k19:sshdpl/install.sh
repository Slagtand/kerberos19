#!/bin/bash

# Creació users
bash /opt/docker/users.sh

# Configuració sshd
ssh-keygen -A
cp /opt/docker/sshd_config /etc/ssh/

# Configuració ldpa, kerberos
authconfig --enableshadow --enablelocauthorize \
   --enableldap \
   --ldapserver='ldap.edt.org' \
   --ldapbase='dc=edt,dc=org' \
   --enablekrb5 --krb5kdc='kserver.edt.org' \
   --krb5adminserver='kserver.edt.org' --krb5realm='EDT.ORG' \
   --enablemkhomedir \
   --updateall

cp /opt/docker/krb5.conf /etc/krb5.conf

# Obtenim la keytab per a que sigui un servidor kerberitzat

kadmin -p admin -w admin -q "addprinc -randkey host/sshd.edt.org"
kadmin -p admin -w admin -q "ktadd host/sshd.edt.org"