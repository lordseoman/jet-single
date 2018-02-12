#!/bin/bash

echo "Doing first time setup..\n"

echo -n "Enter your Fullname: "
read FULLNAME
echo -n "Enter your Bazaar username: "
read USERNAME
echo -n "Enter your email address: "
read EMAIL

bzr whoami "${FULLNAME} <${EMAIL}>"
bzr obs-login $USERNAME

cd 
mkdir -p .bazaar/plugins
cd .bazaar/plugins/
bzr branch bzr+ssh://${USERNAME}@svn.obsidian.com.au/home/bzr/.plugins/obsidian/
cd

echo -n "Enter the client repository: "
read CLIENT
echo -n "Enter the branch [central]: "
read BRANCH

bzr obs-branch --repo=${BRANCH:-devel} ${CLIENT} ${CLIENT}-${BRANCH:-devel}
ln -sv ${CLIENT}-${BRANCH:-devel} Jet
cd Jet/etc
ln -s ../local/etc/licence.key .
ln -s ../local/etc/realm.cfg .
ln -s ../local/etc/local.cfg .
cd ../

if [ -e /opt/Reports ]; then
    cd local/var/
    ln -s /opt/Reports reports_repo
    cd ../../
fi

cd modules/reportfe
python setup.py egg_info

cd 
mkdir Jet/var/log/supervisord
touch Jet/var/log/supervisord/pylons.log
touch Jet/var/log/supervisord/pylons.err
touch Jet/var/log/supervisord/radius.log
touch Jet/var/log/supervisord/radius.err
touch Jet/var/log/supervisord/supervisord.log
chown jet:jet -R Jet/var/log

