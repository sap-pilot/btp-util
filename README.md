# btp-util
BTP command line utilities

## cf - Cloud Foundry

### gen-default-env - Generate default-env.json file for specified app

usage:

    1. cf login
    2. node gen-default-env.js <CF_APP_NAME>

or use in npm script

    scripts: {"gen-env": "CF_APP_NAME=<CF_APP_NAME> && curl https://raw.githubusercontent.com/sap-pilot/btp-util/main/cf/gen-default-env.js | node"}