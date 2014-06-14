require("coffee-script");

var APNSServer = require('./lib/apns_server');

(new APNSServer).start();