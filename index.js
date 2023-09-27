const cds = require('@sap/cds')

/**
 * Resolve destination with consideration of "destOverrides" passed from URL parameter
 * @param request - cds request, the request might have an URL parameter 'destOverrides' with value like 'OLD_DEST_1|NEW_DEST_1,OLD_DEST_2|NEW_DEST_2'
 * @param {string} requiredDestination - required destination in package.json -> requires section
 * @returns {string} - if no override is found, returns the original requiredDestination
 * @returns object - if override is identified & allowed, return cds.env.requires structure with destination overrided 
 * 
 */
module.exports = {
    resolveDestination: function (request, requiredDestination) {
        const destDef = cds.env.requires[requiredDestination]; // take destination config from package.json cds.requires 
        const destOverrides = (request && request.req && request.req.query) ? request.req.query.destOverrides : null; // take url parameter "destOverrides": CSV string of OLD_DEST|NEW_DEST
        if (!destOverrides || !destDef || !destDef.credentials || !destDef.credentials.destination)
            return requiredDestination; // nothing to override
        // need to override destination, copy config first
        const destOverrideWhitelistExp = process.env.DEST_OVERRIDE_WHITELIST_EXP;
        let destExp = null;
        if (!destOverrideWhitelistExp) {
            console.log("# warning: no DEST_OVERRIDE_WHITELIST_EXP specified in ENV, all destOverrides are permitted now.")
        } else {
            destExp = new RegExp(destOverrideWhitelistExp, "i"); // case insensitive
        }
        const newDestDef = JSON.parse(JSON.stringify(destDef));
        const aOverrides = destOverrides.split(",");
        for (const override of aOverrides) {
            const pair = override.split("|");
            if (pair.length == 2 && pair[0] === destDef.credentials.destination) {
                // found override now checking against whitelist
                const newDest = pair[1];
                if (destExp && !destExp.test(newDest)) {
                    console.log("# warning: destOverride '" + newDest + "' not allowed by DEST_OVERRIDE_WHITELIST_EXP '" + destOverrideWhitelistExp + "'");
                } else {
                    console.log("# info: override destination [" + newDestDef.credentials.destination + "] with [" + newDest + "]");
                    newDestDef.credentials.destination = newDest;
                    return newDestDef;
                }
            } else {
                console.log("# warning: cannot recognize destOverride pair [" + override + "]");
            }
        }
        console.log("# warning: no override found, returning original destinaion '" + requiredDestination + "'");
        return requiredDestination;
    }
}