# btp-util
BTP command line utilities

## cf - Cloud Foundry

### 1. gen-default-env.sh - Generate default-env.json file for specified app

usage:

    1. cf login
    2. node gen-default-env.js <CF_APP_NAME>

or use in npm script

    scripts: {"gen-env": "CF_APP_NAME=<CF_APP_NAME> && curl https://raw.githubusercontent.com/sap-pilot/btp-util/main/cf/gen-default-env.js | node"}

### 2. export-service-key.sh - Export flattern service key into env variables

usage: 

    1. set below environment variables:
        export CF_SERVICE_NAME=cloudTransportManagement
        export CF_SERVICE_PREFIX=tms
    2. source this script (to include variables into current process)
        source ./export-service-key.sh 

### 3. export-auth-token.sh - Authenticate with above service key then export auth token

usage:

    1. set below environment variables:
        export CF_SERVICE_NAME=cloudTransportManagement
        export CF_SERVICE_PREFIX=tms
    2. source this script (to include variables into current process)
        source ./export-auth-token.sh 

## integration - Integration Suite 

### 1. int-download-all.sh - Download all integration artifacts and extract it to current folder

usage:

    1. generate then copy the service key of Process Integration Runtime instance with "api" plan (with "AuthGroup_IntegrationDeveloper" role)
    2. condense the service key into single line for instance replaceAll("\n(\s)*',"")
    3. run below command to export service key
        export cpiServiceKey='<CONDENSED_CPI_SERVICE_KEY>'
    3. run below command to download all integration artifacts into current folder
        bash <(curl -s https://raw.githubusercontent.com/sap-pilot/btp-util/main/integration/int-download-all.sh)

result:

  - All integration arfiacts will be downloaded into current folder with structure below
      - <PACKAGE_ID>
          - <IFLOW_NAME>
              - <IFLOW FILES>

## tms - Transport Management Service

### 1. upload-file.sh - Upload mta to specified TMS node and genarate Transport Request 

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