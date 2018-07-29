var exec = require('cordova/exec');

exports.track = function (arg0, success, error) {
    console.log("Tracking Function Found");
    exec(success, error, 'NetCoreIOSCordovaSDK', 'track', [arg0]);
};
