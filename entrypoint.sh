#!/bin/sh

set -x

if [ ! -e /etc/ssh/ssh_host_rsa_key ]; then
  echo "No SSH host key available. Generating one..."
  export LC_ALL=C
  export DEBIAN_FRONTEND=noninteractive
  dpkg-reconfigure openssh-server
fi

cd /home/git

if [ -n "${GIT_UID}" ]; then
    usermod -u ${GIT_UID} git
fi

if [ -n "${GIT_GID}" ]; then
    groupmod -g ${GIT_GID} git
fi

chown -R git:git ./

# Always make sure the git user has a private key you may
# use for mirroring setups etc.
if [ ! -f ./.ssh/id_rsa ]; then
   su git -c "ssh-keygen -f /home/git/.ssh/id_rsa  -t rsa -N ''"
   echo "Here is the public key of the container's 'git' user:"
   cat /home/git/.ssh/id_rsa.pub
fi

# Support trusting hosts for mirroring setups.
if [ ! -f ./.ssh/known_hosts ]; then
    if [ -n "$TRUST_HOSTS" ]; then
        echo "Generating known_hosts file with $TRUST_HOSTS"
        su git -c "ssh-keyscan -H $TRUST_HOSTS > /home/git/.ssh/known_hosts"
    fi
fi

if [ ! -d ./.gitolite ] ; then
   # if there is an existing repositories/ folder, it must
   # have been bind-mounted; we need to make sure it has the
   # correct access permissions.
   if [ -d ./repositories ] ; then
       chown -R git:git repositories
   fi

   # gitolite needs to be setup
   if [ -n "$SSH_KEY" ]; then
       echo "Initializing gitolite, while authorizing your selected key for the admin repo"
       echo "$SSH_KEY" > /tmp/admin.pub
       su git -c "${GITOLITE_HOME}/gitolite setup -pk /tmp/admin.pub"
       rm /tmp/admin.pub
   else
       # If no SSH key is given, we instead try to support
       # bootstrapping from an existing gitolite-admin.

       # Unfortunately, gitolite setup will add a new
       # commit to an existing gitolite-admin dir that
       # resets everything. We avoid this by renaming it first.
       if [ -d ./repositories/gitolite-admin.git ]; then
           mv ./repositories/gitolite-admin.git ./repositories/gitolite-admin.git-tmp
       fi

       # First, setup gitolite without an ssh key.
       # My understanding is that this is essentially a noop,
       # auth-wise. setup will still generate the .gitolite
       # folder and .gitolite.rc files.
       echo "Initializing gitolite without authorizing a key for accessing the admin repo"
       su git -c "${GITOLITE_HOME}/gitolite setup -a dummy"

       # Remove the gitolite-admin repo generated by setup.
       if [ -d ./repositories/gitolite-admin.git-tmp ]; then
           rm -rf ./repositories/gitolite-admin.git
           mv ./repositories/gitolite-admin.git-tmp ./repositories/gitolite-admin.git
       fi

       # Apply config customizations. We need to do this now,
       # because w/o the right config, the compile may fail.
       rcfile=/home/git/.gitolite.rc
       sed -i "s/GIT_CONFIG_KEYS.*=>.*''/GIT_CONFIG_KEYS => \"${GIT_CONFIG_KEYS}\"/g" $rcfile
       if [ -n "$LOCAL_CODE" ]; then
           sed -i "s|# LOCAL_CODE.*=>.*$|LOCAL_CODE => \"${LOCAL_CODE}\",|" $rcfile
       fi

       # We will need to update authorized_keys based on
       # the gitolite-admin repo. The way to do this is by
       # triggering the post-update hook of the gitolite-admin
       # repo (thanks to sitaram for the solution):
       su git -c "cd /home/git/repositories/gitolite-admin.git && GL_LIBDIR=$(${GITOLITE_HOME}/gitolite query-rc GL_LIBDIR) PATH=$PATH:${GITOLITE_HOME}/ hooks/post-update refs/heads/master"
   fi
else
    # Resync on every restart
    su git -c "${GITOLITE_HOME}/gitolite setup"
fi

echo "Executing $*"
exec $*
