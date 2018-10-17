# harobed/gitolite Docker image demo

## Prerequisites

* Docker and Docker-compose
* You need a ssh public key in `~/.ssh/id_rsa.pub` file


## Start Gitolite server

In `demo/` directory:

```
$ export SSK_KEY=$(cat ~/.ssh/id_rsa.pub)
$ docker-compose up -d
$ docker-compose ps
```


## How to push repository to Gitolite?

By default, Gitolite configure a default repository named `testing`.

This is how to push local Git repository to `testing` Gitolite:

```
$ mkdir testing
$ cd testing
$ git init
$ echo "Foobar" > README.md
$ git add README.md
$ git commit -m "First import"
$ git remote add origin ssh://git@127.0.0.1:1234/testing
$ git push origin master
```


## How create add new repos?

First I clone the Gitolite Git admin repository locally:

```
$ git clone ssh://git@127.0.0.1:1234/gitolite-admin
Clonage dans 'gitolite-admin'...
The authenticity of host '[127.0.0.1]:1234 ([127.0.0.1]:1234)' can't be established.
ECDSA key fingerprint is SHA256:+MyvsTjZavm/OgND4mQjH/O3ZoPSUZPAba91gpaB8Pg.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[127.0.0.1]:1234' (ECDSA) to the list of known hosts.
remote: Counting objects: 6, done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 6 (delta 0), reused 0 (delta 0)
Réception d'objets: 100% (6/6), fait.
```

This is the current configuration:

```
$ cat gitolite-admin/conf/gitolite.conf
repo gitolite-admin
    RW+     =   admin

repo testing
    RW+     =   @all
```

Add `foo` repository:

```
$ echo "
repo foo
    RW+     =   @all
" >> gitolite-admin/conf/gitolite.conf
```

Push `gitolite-admin` content to apply new configuration:

```
$ (cd gitolite-admin; git commit -a -m "Add foo repository"; git push origin master)
[master 2ba0d3d] Add foo repository
 1 file changed, 4 insertions(+)
Énumération des objets: 7, fait.
Décompte des objets: 100% (7/7), fait.
Compression par delta en utilisant jusqu'à 8 fils d'exécution
Compression des objets: 100% (3/3), fait.
Écriture des objets: 100% (4/4), 395 bytes | 395.00 KiB/s, fait.
Total 4 (delta 0), réutilisés 0 (delta 0)
remote: Initialized empty Git repository in /home/git/repositories/foo.git/
To ssh://127.0.0.1:1234/gitolite-admin
   0db78a6..2ba0d3d  master -> master
```

Now you can clone `foo` repository:

```
$ git clone ssh://git@127.0.0.1:1234/foo
Cloning into 'foo'...
warning: You appear to have cloned an empty repository.
```

More informations see [Gitolite - basic administration](http://gitolite.com/gitolite/basic-admin/) documentation.
