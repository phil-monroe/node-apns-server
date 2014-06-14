tls            = require('tls')
fs             = require('fs')
APNSConnection = require('./apns_connection')

module.exports = class APNSServer
  HOST = '127.0.0.1'
  PORT = 7777

  options = {
    key: fs.readFileSync('./certs/server-key.pem'),
    cert: fs.readFileSync('./certs/server-cert.pem'),
    allowHalfOpen: true,

    # // This is necessary only if using the client certificate authentication.
    requestCert: true

    # // This is necessary only if the client uses the self-signed certificate.
    # ca: [ fs.readFileSync('client-cert.pem') ]
  }

  constructor: () ->
    @connections = []
    @server = tls.createServer options, @newConnection
    console.log(this)

  newConnection: (conn) =>
    new APNSConnection(this, conn)
    console.log('new connection')

  start: =>
    @server.listen PORT, HOST, () ->
      console.log('server bound')
