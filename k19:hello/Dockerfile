FROM fedora:27
LABEL author="@edt ASIX M11-SAD"
LABEL description="SSH server amb autenticació PAM: kerb5+ldap  2019-2020"
RUN dnf -y install  httpd nmap
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/startup.sh /opt/docker/install.sh
WORKDIR /opt/docker
EXPOSE 80
CMD [ "/opt/docker/startup.sh" ]