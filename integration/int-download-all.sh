# Download all integration artifacts and extract it to current folder
#
# Usage:
# 1. generate then copy the service key of Process Integration Runtime instance with "api" plan (with "AuthGroup_IntegrationDeveloper" role)
# 2. condense the service key into single line for instance replaceAll("\n(\s)*',"")
# 3. run below command to export service key
#     export cpiServiceKey='<CONDENSED_CPI_SERVICE_KEY>'
# 3. run below command to download all integration artifacts into current folder
#     bash <(curl -s https://raw.githubusercontent.com/sap-pilot/btp-util/main/integration/int-download-all.sh)
#
# result:
#   - All integration arfiacts will be downloaded into current folder with structure  below
#       - <PACKAGE_ID>
#           - <IFLOW_NAME>
#               - <IFLOW FILES>

# flattern service key and export key=value
echo $cpiServiceKey | jq -r '[ paths(scalars) as $p | { "key": $p | join("_") | sub("-";"_"), "value": getpath($p) } ] | from_entries' > tmp-flat-cpi-keys.json
OLD_IFS=$IFS
IFS=$'\n' # make newlines the only separator
echo "# exported following env variables:"
for s in $(echo $values | jq "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" tmp-flat-cpi-keys.json | sed -e "s/^\"//g" -e "s/\"$//g"); do
    echo cpi_$s
    export cpi_$s
done
IFS=$OLD_IFS

# retrieve cpi access token
basicAuth=$(echo "$cpi_oauth_clientid:$cpi_oauth_clientsecret")
printf "\n# Getting Token from SAP Process Runtime Service (it-rt.api)...\n"
curl --silent -u "$basicAuth" -X GET "$cpi_oauth_tokenurl?grant_type=client_credentials" > tmp-cpi-token.json
cat tmp-cpi-token.json ; echo
export cpiToken=$(jq -r '.access_token' tmp-cpi-token.json)

# download list of cpi packages
printf "\n# Get CPI Packages...\n"
curl --silent -H "Authorization:Bearer $cpiToken" -H "Accept: application/json" -X  GET "$cpi_oauth_url/api/v1/IntegrationPackages" > tmp-packages.json
cat tmp-packages.json ; echo

# flattern json into list of package ids
jq -r ".d.results[].Id" tmp-packages.json > tmp-packages.txt
cat tmp-packages.txt ; echo

# handling packages one by one
OLD_IFS=$IFS
IFS=$'\n' # make newlines the only separator
for p in $(cat tmp-packages.txt); do
    iflowUrl="$cpi_oauth_url/api/v1/IntegrationPackages('$p')/\$value"
    echo "# Downloading Package '$p' from '$iflowUrl'"
    curl -H "Authorization:Bearer $cpiToken" -X GET "$iflowUrl" -L -o tmp-package-$p.zip
    unzip tmp-package-$p.zip -d $p
    if [ ! -d "$p" ] ; then
        echo "# - Error: not able to unzip package from tmp-package-$p.zip (see content below)"
        cat tmp-package-$p.zip ; echo
        rm tmp-package-$p.zip
        continue
    fi
    files="$p/*_content"
    for f in $files
    do 
        echo "# - Processing $f"
        unzip $f -d tmp-artifact
        if [ ! -f "tmp-artifact/.project" ] ; then
            echo "# - Error: not able to unzip or no .project presented in $f"
            # TODO: try to extract artifact name from META-INF/MANIFEST.MF?
            rm -rf tmp-artifact            
        else
            # extract artifact <name> from .project
            artifactName=`awk -F "[><]" '/name/{print $3}' tmp-artifact/.project | head -1`
            echo "# - Extracted artifactName=$artifactName"
            echo "# - Move artifact to $p/$artifactName"
            mv tmp-artifact $p/$artifactName
        fi
        # delete the zip file
        rm $f 
    done
    rm tmp-package-$p.zip
done
IFS=$OLD_IFS

# clean up & end the script
rm tmp-cpi-token.json
rm tmp-flat-cpi-keys.json
rm tmp-packages.json
rm tmp-packages.txt

printf "\n# -- End of Integration Artifacts Download --\n"