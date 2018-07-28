var exec = require('cordova/exec');

exports.track = function (arg0, success, error) {
    exec(success, error, 'NetCoreIOSCordovaSDK', 'track', [arg0]);
};
