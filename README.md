# btp-util
BTP command line utilities

## cf - Cloud Foundry

### gen-default-env - Generate default-env.json file for specified app

usage:

    1. cf login
    2. node gen-default-env.js <CF_APP_NAME>

or use in npm script

    scripts: {"gen-env": "CF_APP_NAME=<CF_APP_NAME> && curl https://raw.githubusercontent.com/sap-pilot/btp-util/main/cf/gen-default-env.js | node"}

### export-service-key.sh - Export flattern service key into env variables

usage: 

    1. set below environment variables:
        export CF_SERVICE_NAME=cloudTransportManagement
        export CF_SERVICE_PREFIX=tms
    2. source this script (to include variables into current process)
        source ./export-service-key.sh 

## export-auth-token.sh - Authenticate with above service key then export auth token

usage:

    1. set below environment variables:
        export CF_SERVICE_NAME=cloudTransportManagement
        export CF_SERVICE_PREFIX=tms
    2. source this script (to include variables into current process)
        source ./export-auth-token.sh 

## tms - Transport Management Service

### upload-file.sh - Upload mta to specified TMS node and genarate Transport Request 

usage: 

    1. set below environment variables:
        export CF_SERVICE_PREFIX=tms
        export CF_SERVICE_NAME=<YOUR_TMS_SERVICE_NAME>
        export TMS_NODE_NAME=<YOUR_TMS_NODE_NAME>
        export TMS_FILE_NAME=<MTA_FILE_TO_UPLOAD>
    2. cf login
    3. retrieve & export service key & auth token
        source ../cf/export-service-key.sh
        source ../cf/export-auth-token.sh
    4. source this script (to export generated transport request $TMS_TRANSPORT_ID)
        source ./upload-file.sh 