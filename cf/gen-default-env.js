// Get CF environment variables then produce default-env.json for cds watch local run
// usage:
//   1. cf login
//   2. node gen-default-env.js <CF_APP_NAME>
// or use in npm script
//   - scripts: {'gen-env': 'CF_APP_NAME=<CF_APP_NAME> && curl https://raw.githubusercontent.com/sap-pilot/btp-util/main/cf/gen-default-env.js | node'}
const fs = require('fs');
const { execSync } = require("child_process");
const APP_NAME = process.argv[2] || process.env.CF_APP_NAME;
const ENV_FILE_NAME = 'tmp-cf-env.txt';
const OUTPUT_FILE_NAME = 'default-env.json';

var VCAP_SERVICES = null;

console.log("# generating default-env.json for app ["+APP_NAME+"]");
if (!APP_NAME) {
    console.log("# aborting - no CF_APP_NAME specified, use 'node gen-default-env.js <CF_APP_NAME>' or 'export CF_APP_NAME=<CF_APP_NAME>' first");
    process.exit(1);
}

// dump environment variables into ENV_FILE_NAME
execSync("cf env "+APP_NAME+" > "+ENV_FILE_NAME, (error, stdout, stderr) => {
    if (error) {
        console.log(`# error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.log(`# stderr: ${stderr}`);
        return;
    }
});

console.log(`# cf env ${APP_NAME} saved to: ${ENV_FILE_NAME}`);

// read file
const allFileContents = fs.readFileSync(ENV_FILE_NAME, 'utf-8');
var lines = allFileContents.split(/\r?\n/);
for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    if (line.indexOf("VCAP_SERVICES") > -1) {
        VCAP_SERVICES = []; // start reading lines
        VCAP_SERVICES.push('{"VCAP_SERVICES":{');
    }
    else if (line.indexOf('VCAP_APPLICATION') > -1) {
        // stop reading lines
        VCAP_SERVICES.push("}");
        break;
    } else if (VCAP_SERVICES != null) {
        // already started, save current line
        VCAP_SERVICES.push(line);
    }
}

if (!VCAP_SERVICES) {
    console.log(`# no VCAP_SERVICES found in: ${ENV_FILE_NAME}`);
    process.exit(1);
}

// write to default-env.json
var file = fs.createWriteStream(OUTPUT_FILE_NAME);
file.on('error', function(error) { console.log(`error: ${error.message}`); });
VCAP_SERVICES.forEach(function(line) { file.write(line + '\n'); });
file.end();

// clean up ENV_FILE_NAME
fs.unlinkSync(ENV_FILE_NAME);

console.log(`# cf env ${APP_NAME} converted to: ${OUTPUT_FILE_NAME}`);