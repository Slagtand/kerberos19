# Host amb kerberos i ldap

En aquest contàiner farem un host client de kerberos i ldap.

El kerberos serà el nostre **AP** (*Authenthication Provider*) i el ldap serà el nostre **IP** (*Information Provider*) 

## Instal·lació

* Per a accedir als dos servidors hem d'instal·lar els següents paquets
  
  ```bash
  # Per kerberos
  dnf -y install krb5-workstation pam_krb5 passwd
  # Per ldap
  
  ```








