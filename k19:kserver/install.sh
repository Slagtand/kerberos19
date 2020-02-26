#!/bin/bash

cp /opt/docker/krb5.conf /etc/krb5.conf
cp /opt/docker/kdc.conf /var/kerberos/krb5kdc/kdc.conf
cp /opt/docker/kadm5.acl /var/kerberos/krb5kdc/kadm5.acl

kdb5_util create -s -P masterkey

kadmin.local -q "addprinc -pw admin admin"
for num in {01..06}
do
    kadmin.local -q "addprinc -pw kuser$num kuser$num"
done

users=["jordi", "marta", "anna", "pere", "pau"]
for user in $users
do
    kadmin.local -q "addprinc -pw k$user $user"
done

