# Extract auth token to env variable
# usage
#    1. set below environment variables:
#        export CF_SERVICE_PREFIX=tms
#        export CF_SERVICE_NAME=<YOUR_TMS_SERVICE_NAME>
#        export TMS_NODE_NAME=<YOUR_TMS_NODE_NAME>
#        export TMS_FILE_NAME=<MTA_FILE_TO_UPLOAD>
#    2. cf login
#    3. retrieve & export service key & auth token
#        source ../cf/export-service-key.sh
#        source ../cf/export-auth-token.sh
#    4. source this script (to export generated transport request $TMS_TRANSPORT_ID)
#        source ./upload-file.sh 

# echo input prams
echo "# CF_SERVICE_PREFIX=${CF_SERVICE_PREFIX}"
echo "# TMS_NODE_NAME=${TMS_NODE_NAME}"
echo "# TMS_FILE_NAME=${TMS_FILE_NAME}"
CF_AUTH_TOKEN_NAME=${CF_SERVICE_PREFIX}_token
CF_AUTH_TOKEN=${!CF_AUTH_TOKEN_NAME}

# echo auth token and tms params (from service-key)
echo "# CF_AUTH_TOKEN=${CF_AUTH_TOKEN}"
TMS_URL_KEY=${CF_SERVICE_PREFIX}_credentials_uri
TMS_URL=${!TMS_URL_KEY}
echo "# TMS_URL=${TMS_URL}"

# upload file to tms service
curl -H "Authorization:Bearer ${CF_AUTH_TOKEN}" -F "file=@${TMS_FILE_NAME}" -X POST ${TMS_URL}/v2/files/upload > tmp-tms-file-id.json
TMS_FILE_ID=$(jq -r '.fileId' tmp-tms-file-id.json)
echo "# Uploaded TMS_FILE_ID=${TMS_FILE_ID}"

# attach file to specified tms node
TMS_FILE_DESC=$(echo "BTP-MTA[${TMS_FILE_ID}]: ${TMS_FILE_NAME}")
echo "# TMS_FILE_DESC=${TMS_FILE_DESC}"
jq -n --arg uri $TMS_FILE_ID --arg node ${TMS_NODE_NAME} --arg desc "${TMS_FILE_DESC}" '{"nodeName":$node,"contentType":"MTA","storageType":"FILE","entries":[{"uri":$uri}],"description":$desc}' > tmp-tms-upload-payload.json
echo "# TMS upload payload:"
cat tmp-tms-upload-payload.json
echo "# Uploading file to TMS Node [${TMS_NODE_NAME}]..."
TMS_UPLOAD_STATUS=$(curl -H "Authorization:Bearer ${CF_AUTH_TOKEN}" -H "Content-Type:application/json" -w '%{http_code}\n' -d @tmp-tms-upload-payload.json -X POST ${TMS_URL}/v2/nodes/upload --output tmp-tms-upload-output.json)

# echo upload result
echo "# TMS_UPLOAD_STATUS=${TMS_UPLOAD_STATUS}"
TMS_TRANSPORT_ID=$(jq -r '.transportRequestId' tmp-tms-upload-output.json)
echo "# Result: TMS_TRANSPORT_ID=${TMS_TRANSPORT_ID}"