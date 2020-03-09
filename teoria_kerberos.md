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

#### Definir ACL's

Podem definir les **acl** dels usuaris principal a `/var/kerberos/krb5kdc/kadm5.acl` 

```bash
*/admin@EDT.ORG        *
superuser@EDT.ORG    *
pau/admin@EDT.ORG    *
marta@EDT.ORG        *
```

#### Afegir usuaris

`kadmin.local` ens permet executar les ordres de forma local com si ens connectessim amb `kadmin`

Crear usuaris principals

```bash

```







 
