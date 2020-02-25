#!/bin/bash

cp /opt/docker/krb5.conf /etc/krb5.conf
cp /opt/docker/system-auth /etc/pam.d/system-auth
bash /opt/docker/users.sh