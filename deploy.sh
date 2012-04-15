#/bin/bash
meteor bundle babble.tar.gz
tar -xf babble.tar.gz
cp -r bundle/* ../babble-deploy
rm babble.tar.gz
rm -r bundle

cd ../babble-deploy
git checkout -- server/server.js
rm -r server/node_modules/fibers
git push heroku master