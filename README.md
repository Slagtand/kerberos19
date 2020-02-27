# kerberos19

Repositori de kerberos per m11 asix edt

docker build -t marcgc/k19:kserver .

docker run --rm --name kserver.edt.org -h kserver.edt.org --net mynet -d marcgc/k19:kserver

## k19:khostpl

* Client que agafa les dades de l'usuari del servidor ldap i s'autentica contra el servidor kerberos

* Passos a seguir:
  
  * Arrencar els servidors kerberos (*kserver.edt.org*) i ldap (*ldap.edt.org*)
    
    ```bash
    docker run --rm --name kserver.edt.org -h kserver.edt.org -p 464:464 -p 749:749 -p 88:88 -d marcgc/k19:kserver
    #
    docker run --rm --name ldap.edt.org -h ldap.edt.org -p 389:389 -d marcgc/ldapserver19:kerberos (o latest)
    ```
  
  * Arrenquem el host
    
    ```bash
    docker run --rm --name khost.edt.org -h khost.edt.org --net mynet -it marcgc/k19:khostpl
    ```
  
  * Comprovem que obtenim les dades del ldap
    
    ```bash
    [root@khost docker]# getent passwd
    [...]
    pau:*:5000:100:Pau Pou:/tmp/home/pau:
    pere:*:5001:100:Pere Pou:/tmp/home/pere:
    anna:*:5002:600:Anna Pou:/tmp/home/anna:
    marta:*:5003:600:Marta Mas:/tmp/home/marta:
    jordi:*:5004:100:Jordi Mas:/tmp/home/jordi:
    admin:*:10:10:Administrador Sistema:/tmp/home/admin:
    user01:*:7001:610:user01:/tmp/home/1asix/user01:
    user02:*:7002:610:user02:/tmp/home/1asix/user02:
    user02:*:7003:610:user03:/tmp/home/1asix/user03:
    user04:*:7004:610:user04:/tmp/home/1asix/user04:
    user05:*:7005:610:user05:/tmp/home/1asix/user05:
    user06:*:7006:611:user06:/tmp/home/2asix/user06:
    user07:*:7007:611:user07:/tmp/home/2asix/user07:
    user08:*:7008:611:user08:/tmp/home/2asix/user08:
    user09:*:7009:611:user09:/tmp/home/2asix/user09:
    user10:*:7010:611:user10:/tmp/home/2asix/user10:
    ```
  
  * Comprovem que podem contactar, i accedir, amb el servidor kerberos
    
    ```bash
    [root@khost docker]# kinit pere
    Password for pere@EDT.ORG: 
    [root@khost docker]# klist
    Ticket cache: FILE:/tmp/krb5cc_0
    Default principal: pere@EDT.ORG
    
    Valid starting     Expires            Service principal
    02/27/20 08:42:58  02/28/20 08:42:58  krbtgt/EDT.ORG@EDT.ORG
    [root@khost docker]# kadmin -p admin
    Authenticating as principal admin with password.
    Password for admin@EDT.ORG: 
    kadmin:  listprincs
    K/M@EDT.ORG
    admin@EDT.ORG
    anna@EDT.ORG
    jordi@EDT.ORG
    kadmin/admin@EDT.ORG
    kadmin/changepw@EDT.ORG
    kadmin/kserver.edt.org@EDT.ORG
    kiprop/kserver.edt.org@EDT.ORG
    krbtgt/EDT.ORG@EDT.ORG
    kuser01@EDT.ORG
    kuser02@EDT.ORG
    kuser03@EDT.ORG
    kuser04@EDT.ORG
    kuser05@EDT.ORG
    kuser06@EDT.ORG
    marta@EDT.ORG
    pau@EDT.ORG
    pere@EDT.ORG
    user01@EDT.ORG
    ```
  
  * Per a que busqui al servidor ldap ens hem d'assegurar que */etc/nsswitch.conf* tingui les següents línies:
    
    ```bash
    
    ```
