FROM fedora:27
LABEL autor="@marcgc"
LABEL description="server kerberos"

RUN dnf -y install krb5-server krb5-workstation

RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh

WORKDIR /opt/docker
CMD [ "/opt/docker/startup.sh" ]