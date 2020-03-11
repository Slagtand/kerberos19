# Kerberos

Kerberos és un protocol d'**autenticació** de xarxes d'ordinador creat pel MIT (*Massachussets Institute of Technology*) que permet a dues màquines, en una xarxa insegura, demostrar la seva identitat de forma segura.

Tant el client com el servidor verifican l'identitat de l'altre, estant protegits els missatges d'autenticació per evitar [eavesdropping](https://es.wikipedia.org/wiki/Eavesdropping) i [atacs de replay](https://es.wikipedia.org/wiki/Ataque_de_REPLAY).

Kerberos es basa en la criptografia de clau simètrica i necessita d'un tercer de confiança, és a dir, l'usuari es conecta al servidor kerberos i obté un tiquet. Aquest tiquet és la prova de qui ets.

En els servidors kerberitzats els usuaris presenten el seu tiquet i aquests es comuniquen amb el servidor kerberos per verificar qui és i autenticar.

Amb **klist** mostrem els tiquets que tenim actualment:

```bash
[isx47787241@i09 curs]$ klist
Ticket cache: FILE:/tmp/krb5cc_101709_6EW9wO
Default principal: isx47787241@INFORMATICA.ESCOLADELTREBALL.ORG

Valid starting     Expires            Service principal
18/02/20 08:46:52  19/02/20 08:46:52  krbtgt/INFORMATICA.ESCOLADELTREBALL.ORG@INFORMATICA.ESCOLADELTREBALL.ORG
18/02/20 08:46:56  19/02/20 08:46:52  nfs/madiba.informatica.escoladeltreball.org@INFORMATICA.ESCOLADELTREBALL.ORG
```

## Autenticació i autorització

**Auth** autenticació (qui sóc)

* **AP authentication provider**: són els mètodes d'autenticació, verifiquen qui ets. Kerberos proporciona el servei de proveïdor d'autenticació. **No emmagatzema l'informació dels comptes d'usuari** com l'uid, git, shell... Simplement emmagatzema i gestiona els **passwords** dels usuaris en entrades anomenades **principals** a la seva base de dades.
  
  Coneixem els següents AP:
  
  * `/etc/passwd` conté els password (AP) i també la informació del comptes d'usuari (IP).
  
  * `ldap` el servei de directori ldap conté informació dels comptes d'usuari (IP) i també els seus passwords (AP).
  
  * `kerberos` únicament actua d'AP i no d'IP.

**Autz** authorization (què tinc dret a fer)

* **IP information provider**: donen informació sobre el compte i els teus privilegis. Emmagatzemen la informació dels comptes d'usuari tals com l'uid, gid, shell, gecos... Els clàssics són `/etc/passwd` i `ldap`.

## Serveis de Kerberos

Kerberos utilitza tres serveis:

```bash
88/tcp open kerberos-sec
464/tcp open kpasswd5
749/tcp open kerberos-adm
```

**kadmind**: dimoni del servei **d'administració** kerberos.

**krb5kdc**: dimoni de kerberos encarregat de **distribució** dels tiquets.

## Instal·lació del server

Paquets necessaris: 

* `krb5-server`: servidor kerberos

* `krb5-workstation`: client kerberos
  
  ```bash
  dnf -y install krb5-server krb5-workstation
  
  # tree /var/kerberos/
  /var/kerberos/
  ├── krb5
  │ └── user
  └── krb5kdc
    ├── kadm5.acl
    └── kdc.conf
  ```

## Configuració

Modifiquem el fitxer de configuració principal `/etc/krb5.conf` afegint el nostre domini (realm) i especifiquem el servidor:

```bash
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 default_realm = EDT.ORG
# default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EDT.ORG = {
 # servidor kerberos
  kdc = kserver.edt.org
  admin_server = kserver.edt.org
 }

[domain_realm]
 .edt.org = EDT.ORG 
 edt.org = EDT.ORG
```

Fiquem el realm al fitxer `/var/kerberos/krb5kdc/kdc.conf`:

```bash
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 EDT.ORG = {
  #master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  supported_enctypes = aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal camellia256-cts:normal camellia128-cts:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
 }
```

### Crear base de dades

A la base de dades de keberos emmagatzarem les **claus principals** (usuaris i màquines)

```bash
kdb5_util create -s -P masterkey
# verifiquem que s'ha creat
tree /var/kerberos/
/var/kerberos/
├── krb5
│ └── user
└── krb5kdc
  ├── kadm5.acl
  ├── kdc.conf
  ├── principal
  ├── principal.kadm5
  ├── principal.kadm5.lock
  └── principal.ok
```

## Gestió del servidor

`kadmin.local` ens permet executar les ordres a baix nivell de forma local com si ens connectessim amb `kadmin`

`kadmin` és una utilitat d'administració que conecta amb el servidor per xarxa fent servir el protocol kerberos. Es pot utilitzar des de qualsevol client o servidor i estableis una connexió de xarxa segura. Els permisos venen establerts per les ACL's.

* Crear usuaris principals amb `addprinc`
  
  ```bash
  # addprinc -pw password user
  kadmin.local -q "addprinc -pw superuser superuser"
  kadmin.local -q "addprinc -pw admin admin"
  kadmin.local -q "addprinc -pw kpere pere"
  kadmin.local -q "addprinc -pw kmarta marta"
  kadmin.local -q "addprinc -pw kjordi jordi"
  kadmin.local -q "addprinc -pw kpau pau"
  kadmin.local -q "addprinc -pw kpau pau/admin"
  ```

* Llistem els principals amb `list_principals`
  
  ```bash
  [root@kserver /]# kadmin.local -q "list_principals"
  Authenticating as principal root/admin@EDT.ORG with password.
  K/M@EDT.ORG
  admin@EDT.ORG
  jordi@EDT.ORG
  kadmin/admin@EDT.ORG
  kadmin/changepw@EDT.ORG
  kadmin/kserver@EDT.ORG
  kiprop/kserver@EDT.ORG
  krbtgt/EDT.ORG@EDT.ORG
  marta@EDT.ORG
  pau/admin@EDT.ORG
  pau@EDT.ORG
  pere@EDT.ORG
  superuser@EDT.ORG
  ```

* Veiem un principal amb `getprinc`
  
  ```bash
  kadmin:  getprinc kuser06
  kadmin.local -q "getprinc kuser06"
  ```

* Canviem passwords de principals amb `change_password` o `cpw`(abreviat)
  
  ```bash
  kadmin.local -q "change_password kuser02"
  kadmin.local -q "cpw kuser02"
  ```

* Eliminem un principal amb `delprinc`
  
  ```bash
  kadmin.local -q "delprinc kuser02"
  ```

* Modifiquem un principal amb `modprinc`
  
  ```bash
  kadmin: modprinc -expire "12/31 7pm" kuser01
  ```

## Arrencar el servei

```bash
systemctl start bkrb5kdc.service
systemctl start kadmin.service

/usr/sbin/krb5kdc
/usr/bin/kadmind -nofork
```

## Instal·lació del client

Paquets necessaris:

* `krb5-workstation`
  
  ```bash
  [root@kclient /]# dnf install -y krb5-workstation
  ```

### Configuració client

Sol hem de configurar el fitxer `/etc/krb5.conf` per afegir-hi el *realm* amb la sintaxi `REALM = {}` :

```bash
[root@khost /]# vi /etc/krb5.conf
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 default_realm = EDT.ORG
# default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EDT.ORG = {
 # servidor kerberos
  kdc = kserver.edt.org
  admin_server = kserver.edt.org
 }

[domain_realm]
 .edt.org = EDT.ORG 
 edt.org = EDT.ORG
```

### Gestió client

Podem gestionar els tiquets des del client amb:

* Demanem un tiquet amb `klist`
  
  ```bash
  kinit kuser06
  ```

* Llistem els tiquets amb `klist`
  
  ```bash
  [isx47797439@i08 kerberos19]$ klist
  Ticket cache: FILE:/tmp/krb5cc_101710_MVM4K6
  Default principal: isx47797439@INFORMATICA.ESCOLADELTREBALL.ORG
  
  Valid starting       Expires              Service principal
  03/11/2020 11:22:41  03/12/2020 11:22:41  krbtgt/INFORMATICA.ESCOLADELTREBALL.ORG@INFORMATICA.ESCOLADELTREBALL.ORG
  ```

* Canviem la contrasenya amb `kpasswd`
  
  ```bash
  kpasswd        # cambiar password
  Password for kuser06@EDT.ORG: 
  Enter new password: 
  Enter it again: 
  Password changed.
  ```

* Eliminem un tiquet amb `kdestroy`
  
  ```bash
  kdestroy
  ```

## Definició i gestió ACL's

Podem definir les **acl** dels usuaris principal a `/var/kerberos/krb5kdc/kadm5.acl`

```bash
*/admin@EDT.ORG        *
superuser@EDT.ORG    *
pau/admin@EDT.ORG    *
marta@EDT.ORG        *
```

L'ordre de les entrades és **significatiu**. La primera entrada coincident especifica el principal al que se li aplica l'accés de control, ja sigui sol en el principal o en el principal quan opera en un principal objectiu.

La sintaxi de les entrades ACL tenen el següent format:

```bash
principal         operation-mask [operation-target]
*/admin@EDT.ORG       *
superuser@EDT.ORG     *
pau/admin@EDT.ORG     *
marta@EDT.ORG         *
```

* `Operation mask`: Permisos sobre el què es podrà fer. Si l'opció està en *majúscula* **denega** l'acció, mentres que en *minúscula* **aproba** l'acció.
  
  * Per exemple `a` **permet** crear principals, mentres que `A` **denega** crear-ne.
  
  | Opció | Permisos                                                                                                     |
  | ----- | ------------------------------------------------------------------------------------------------------------ |
  | a     | permet crear principals i polítiques                                                                         |
  | c     | permet el canvi de contrasenyes als principals                                                               |
  | d     | permet eliminar principals i polítiques                                                                      |
  | i     | permet consultes sobre els principals i polítiques                                                           |
  | l     | permet llistar principals i polítiques                                                                       |
  | m     | permet modificar principals i polítiques                                                                     |
  | p     | permet la propagació de la base de dades principal (utilitzada en la propagació de base de dades incremental |
  | s     | permet la configuració explícita de la clau per un principal                                                 |
  | x     | abreviació de les opcions admcil. Tots els privilegis                                                        |
  | *     | El mateix que x                                                                                              |
  
  `Operation target`: Opcional. Objecte sobre el qual es podrà aplicar els permisos indicats, si no s'indica és a tots.
  
  Exemples:
  
  ```bash
  # L'user kuser01/admin té permisos de: add, delete, modify sobre tots els usuaris
  kuser01/admin@realm adm
  
  # L'user kuser01 té permisos (canvi contrasenya, modificar i veure dades d'usuari) sobre tots els usuaris del grup instance
  kuser01@EDT.ORG cim */instance@EDT.ORG
  
  # Si hi ha un mach sol s'aplica la primera regla, kuser01 sol pot canviar contrasenyes
  kuser01@EDT.ORG    c
  kuser01@EDT.ORG    * # Aquesta no s'aplica mai
  
  # kuser01 sol pot canviar la contrasenya a kuser05
  kuser01@EDT.ORG    c kuser05@EDT.ORG
  
  # Tots els usuaris poden canviar-se la contrasenya a ells mateixos, però no als demés
  *@EDT.ORG          c    self@EDT.ORG
  
  # kuser01 pot afegir usuaris però no esborrar-los
  kuser01@EDT.ORG    aD
  
  # Tots els usuaris poden canviar-se la seva contrasenya i kuser01, ademés, pot llistar i veure usuaris
  *@EDT.ORG          c    self@EDT.ORG
  kuser01@EDT.ORG    li
  ```

## Serveis kerberitzats

Un servei kerberitzat és aquell que utilitza un server kerberos com autenticador.

Per kerberitzar un servidor hem de:

* Afegir-lo com un principal

* Crear la keytab i afegir-la per al principal
  
  ```bash
  addprinc -randkey host/sshd.edt.org
  ktadd -k /etc/krb5.keytab host/sshd.edt.org
  ```
