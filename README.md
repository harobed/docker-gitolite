# Docker Gittolite

Docker image for [Gittolite](http://gitolite.com/gitolite/index.html)

This Gitolite Docker Image (255Mo) is based on Debian Jessie, I'll maybe migrate it to Alpine in the future.


## Rationalize - « Why yet another Gitolite Docker image project? »

I have created this Gitolite Docker image in june 2017 for a personnal project.

One year later, I have forgotten what project I have forked and why it.

Why do you use Gitolite instead [GitLab](http://gitlab.com/), [Gogs](https://gogs.io/) or [Phabricator](https://www.phacility.com/)?<br />
I would like write a tutorial post to explain how to use [git-subrepo](https://github.com/ingydotnet/git-subrepo) then I need lightning Git hosting on a central server like Gitolite to publish a demo.

Other Gitolite Docker image projects:

* [jgiannuzzi/docker-gitolite](https://github.com/jgiannuzzi/docker-gitolite)
* [baguette-io/baguette-gitolite](https://github.com/baguette-io/baguette-gitolite)


## How to use harobed/gitolite Docker image?

Use this `docker-compose.yml` file:

```
version: '3.7'
services:
  debian:
    image: harobed/gitolite:latest
    environment:
      - SSH_KEY=...your public ssh key...
    ports:
      - "1234:22"
    volumes:
      - ./data/git/:/home/git/repositories/
      - ./data/ssh/:/etc/ssh/
```

Launch it:

```
$ docker-compose up -d
$ git clone ssh://git@127.0.0.1:1234/gitolite-admin
$ cat gitolite-admin/conf/gitolite.conf
repo gitolite-admin
    RW+     =   admin

repo testing
    RW+     =   @all
```

See [`demo/`](demo/) for a comprehensive demo.


## How to build and push harobed/gitolite Docker Image?

```
$ ./scripts/build.sh
$ ./scripts/push.sh
```
