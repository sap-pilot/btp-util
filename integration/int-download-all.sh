# Download all integration artifacts and extract it to specified folder
# Useage:
#  1. export cpiServiceKey=<YOUR_CPI_SERVICE_KEY> - service key of Process Integration Runtime instance with "api" plan (condense into single line)
#  2. source ./int-download-all.sh
# Outcome:
#   - All integration arfiacts will be downloaded into local folder with structure like below
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
cat tmp-cpi-token.json
export cpiToken=$(jq -r '.access_token' tmp-cpi-token.json)

# download list of cpi packages
printf "\n# Get CPI Packages...\n"
curl --silent -H "Authorization:Bearer $cpiToken" -H "Accept: application/json" -X  GET "$cpi_oauth_url/api/v1/IntegrationPackages" > tmp-packages.json
cat tmp-packages.json

# flattern json into list of package ids
jq -r ".d.results[].Id" tmp-packages.json > tmp-packages.txt
cat tmp-packages.txt

# handling packages one by one
OLD_IFS=$IFS
IFS=$'\n' # make newlines the only separator
for p in $(cat tmp-packages.txt); do
    iflowUrl="$cpi_oauth_url/api/v1/IntegrationPackages('$p')/\$value"
    echo "# Downloading Package '$p' from '$iflowUrl'"
    curl --silent -H "Authorization:Bearer $cpiToken" -X GET "$iflowUrl" -o tmp-package-$p.zip
    unzip tmp-package-$p.zip -d $p
    files="$p/*_content"
    for f in $files
    do 
        echo "# - Processing $f"
        unzip $f -d tmp-artifact
        # extract artifact <name> from .project
        artifactName=`awk -F "[><]" '/name/{print $3}' tmp-artifact/.project | head -1`
        echo "# - Extracted artifactName=$artifactName"
        echo "# - Move artifact to $p/$artifactName"
        mv tmp-artifact $p/$artifactName
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