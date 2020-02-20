#!/bin/bash

cp /opt/docker/krb5.conf /etc/krb5.conf
cp /opt/docker/kdc.conf /var/kerberos/krb5kdc/kdc.conf
cp /opt/docker/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl

kdb5_util create -s -P masterkey

kadmin.local -q "addprinc -pw admin admin"
kadmin.local -q "addprinc -pw kuser01 kuser01"
kadmin.local -q "addprinc -pw kuser02 kuser02"
kadmin.local -q "addprinc -pw kuser03 kuser03"
kadmin.local -q "addprinc -pw kuser04 kuser04"
kadmin.local -q "addprinc -pw kuser05 kuser05"
kadmin.local -q "addprinc -pw kuser06 kuser06"
