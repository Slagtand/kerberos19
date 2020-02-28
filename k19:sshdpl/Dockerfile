FROM fedora:27
LABEL autor="@marcgc"
LABEL description="client kerberos amb ldap"

RUN dnf -y install krb5-workstation pam_krb5 passwd \
        nss-pam-ldapd authconfig \
        openssh openssh-server openssh-clients

RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh

WORKDIR /opt/docker
CMD [ "/opt/docker/startup.sh" ]