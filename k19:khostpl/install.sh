#!/bin/bash

authconfig --enableshadow --enablelocauthorize \
   --enableldap \
   --ldapserver='ldap.edt.org' \
   --ldapbase='dc=edt,dc=org' \
   --enablekrb5 --krb5kdc='kserver.edt.org' \
   --krb5adminserver='kserver.edt.org' --krb5realm='EDT.ORG' \
   --enablemkhomedir \
   --updateall

cp /opt/docker/krb5.conf /etc/krb5.conf
bash /opt/docker/users.sh