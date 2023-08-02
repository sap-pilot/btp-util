# Export last service key of specified service into env variable
# usage
#    1. set below environment variables:
#        export CF_SERVICE_NAME=cloudTransportManagement
#        export CF_SERVICE_PREFIX=tms
#    2. source this script (to include variables into current process)
#        source ./export-service-key.sh 

# echo input param
echo "# service prfix = [${CF_SERVICE_PREFIX}]"
echo "# service name = [${CF_SERVICE_NAME}]"

# retrive last service key name
export CF_SERVICE_KEY_NAME=$(cf service-keys $CF_SERVICE_NAME | tail -n1 | awk '{print $1}')
echo "# service key name = [${CF_SERVICE_KEY_NAME}]"

# retrieve last service key
cf service-key $CF_SERVICE_NAME $CF_SERVICE_KEY_NAME | tail -n +3 > ${CF_SERVICE_PREFIX}-key.json

# flattern service key and export key=value
jq -r '[ paths(scalars) as $p | { "key": $p | join("_"), "value": getpath($p) } ] | from_entries' ${CF_SERVICE_PREFIX}-key.json > tmp-flat-${CF_SERVICE_PREFIX}-key.json
OLD_IFS=$IFS
IFS=$'\n' # make newlines the only separator
echo "# exported following env variables:"
for s in $(echo $values | jq "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" tmp-flat-${CF_SERVICE_PREFIX}-key.json | sed -e "s/^\"//g" -e "s/\"$//g"); do
    echo ${CF_SERVICE_PREFIX}_$s
    export ${CF_SERVICE_PREFIX}_$s
done
IFS=$OLD_IFS