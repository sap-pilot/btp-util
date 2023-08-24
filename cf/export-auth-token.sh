# Extract auth token to env variable
# usage
#    1. set below environment variables:
#        export CF_SERVICE_NAME=cloudTransportManagement
#        export CF_SERVICE_PREFIX=tms
#    2. source this script (to include variables into current process)
#        source ./export-auth-token.sh 

# echo input param
echo "# CF_SERVICE_PREFIX=${CF_SERVICE_PREFIX}"
echo "# CF_SERVICE_NAME=${CF_SERVICE_NAME}"

# concatenate keys
CF_CLIENT_ID_KEY=${CF_SERVICE_PREFIX}_credentials_uaa_clientid
CF_CLIENT_SECRET_KEY=${CF_SERVICE_PREFIX}_credentials_uaa_clientsecret
CF_AUTH_URL_KEY=${CF_SERVICE_PREFIX}_credentials_uaa_url
CF_CLIENT_ID=${!CF_CLIENT_ID_KEY}
CF_CLIENT_SECRET=${!CF_CLIENT_SECRET_KEY}
CF_AUTH_URL=${!CF_AUTH_URL_KEY}
CF_AUTH_TOKEN_FILE=tmp-${CF_SERVICE_PREFIX}-token.json
echo "# CF_CLIENT_ID=${CF_CLIENT_ID}"
echo "# CF_CLIENT_SECRET=${CF_CLIENT_SECRET}"
echo "# CF_AUTH_URL=${CF_AUTH_URL}"

# curl oauth/token service
curl -u "${CF_CLIENT_ID}:${CF_CLIENT_SECRET}" -X GET ${CF_AUTH_URL}/oauth/token?grant_type=client_credentials > ${CF_AUTH_TOKEN_FILE}

# echo returned oauth token
CF_AUTH_TOKEN=$(jq -r '.access_token' ${CF_AUTH_TOKEN_FILE})
echo "# Exporting following env var:"
echo ${CF_SERVICE_PREFIX}_token=${CF_AUTH_TOKEN}
export ${CF_SERVICE_PREFIX}_token=${CF_AUTH_TOKEN}